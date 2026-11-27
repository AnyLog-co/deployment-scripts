import argparse
import ast
import datetime
import decimal
import json
import psycopg2
import re

CONN=None

def _query_request(cur, query:str):
    try:
        cur.execute(query)
        return cur.fetchall()
    except Exception as err:
        raise Exception(f"Failed to execute query and/or fetch results against {CONN} (Error: {err})")

def _clean_value(value):
    datetime_formats = ["%Y-%m-%d %H:%M:%S.%f", "%Y-%m-%dT%H:%M:%S.%fZ", "%Y-%m-%dT%H:%M:%SZ", "%Y-%m-%d %H:%M:%S"]
    datetime_patterns = re.compile(r'^\d{4}-\d{2}-\d{2}[ T]\d{2}:\d{2}:\d{2}(?:\.\d+)?(?:Z)?$')
    if isinstance(value, datetime.datetime):
        for frmt in datetime_formats:
            try:
                return value.strftime(frmt)
            except:
                continue
        raise Exception(f"Failed to find the proper format for {value}")
    elif isinstance(value,decimal.Decimal):
        value = float(value)
    else:
        try:
            value = ast.literal_eval(value)
        except:
            pass

    return value


def get_tables(cur):
    tables = []
    query = """
        SELECT table_name
        FROM information_schema.tables
        WHERE table_type = 'BASE TABLE'
        AND table_schema NOT IN ('pg_catalog', 'information_schema')
        ORDER BY table_schema, table_name;
    """

    output = _query_request(cur=cur, query=query)
    for value in output:
        if value[0].startswith("par_"):
            tables.append(value[0])
    return tables

def get_data(cur, table):
    remove_keys = {'row_id', 'insert_timestamp', 'tsd_name', 'tsd_id'}

    query = f"SELECT * FROM {table}"

    output = _query_request(cur=cur, query=query)
    columns = [desc[0] for desc in cur.description]
    data = [dict(zip(columns, row)) for row in output]
    results = []

    for row in data:
        item = {}
        for key in row:
            if key in remove_keys:
                continue
            item[key] = _clean_value(row[key])

        results.append(item)
    return results


def main():
    global CONN
    parser = argparse.ArgumentParser()
    parser.add_argument('conn', type=str, default=None,  help="Access for database {user}:{password}@{host}:{port}")
    parser.add_argument('dbms', type=str, default='cos', help="logical database name")
    args = parser.parse_args()

    user, password = args.conn.split('@')[0].split(":")
    CONN = args.conn.split('@')[-1]
    host, port = CONN.split(":")

    try:
        conn = psycopg2.connect(host=host, port=port, user=user, password=password, dbname=args.dbms)
        cur = conn.cursor()
    except Exception as error:
        raise Exception(f"Failed to get connection against {CONN} (Error: {error})")


    tables = get_tables(cur=cur)
    for table in tables:
        data = get_data(cur=cur, table=table)
        print(f"{table} - {len(data)}")
        with open(f"{table}.jon", "w") as f:
            for row in data:
                f.write(f"{json.dumps(row)},\n" if row != data[-1]  else f"{json.dumps(row)}")

if __name__ == '__main__':
    main()
