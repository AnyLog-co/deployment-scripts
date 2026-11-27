import argparse
import csv
import json
import os
import requests

ROOT_DIR = os.path.expanduser(os.path.expandvars(__file__.split("tag")[0]))


def __read_csv(csv_file:str=os.path.join(ROOT_DIR, 'sample_tags.csv'))->list:
    data = []
    if not os.path.isfile(csv_file):
        print(f"Failed to locate CSV file {csv_file}")
        exit(1)
    try:
        with open(csv_file, 'r') as f:
            csv_reader = csv.DictReader(f)
            for row in csv_reader:
                # Parse the 'geoloc' field into a tuple (latitude, longitude)
                if 'loc' in row:
                    row['loc'] = f"{row['loc'].split('(')[-1]}, {row[None][0].split(')')[0]}"
                del row[None]
                data.append(row)
    except Exception as error:
        print(f"Failed to read content in {csv_file} (Error: {error})")
        exit(1)
    return data


def __create_policy(policy_type:str, owner:str, data:dict)->str:
    new_policy = {
        policy_type: {
            "owner": owner
        }
    }
    for key in data:
        new_policy[policy_type][key] = data[key]
    return json.dumps(new_policy, indent=2)


def __publish_policy(conn:str, ledger_conn:str, policy:str):
    new_policy=f"<new_policy={policy}>"
    headers = {
        'command': 'blockchain push !new_policy',
        'User-Agent': 'AnyLog/1.23',
        'destination': ledger_conn
    }

    try:
        r = requests.post(url=f"http://{conn}", headers=headers, data=new_policy)
    except Exception as error:
        print(f"Failed to publish policy (Error: {error})")
    else:
        if not 200 <= int(r.status_code) <= 299:
            print(f"Failed to publish policy (Network Error: {r.status_code})")

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('rest_conn', type=str, default='127.0.0.1:32049', help='REST connection information')
    parser.add_argument('ledger_conn', type=str, default='127.0.0.1:32048', help='Ledger conn TCP information')
    parser.add_argument('--policy-type', type=str, default='device-tag', help='policy type ame')
    parser.add_argument("--csv", type=str, default=os.path.join(ROOT_DIR, 'sample_tags.csv'), help='CSV file with info to store')
    parser.add_argument('--owner', type=str, default='Smart City', help='policy owner')
    args = parser.parse_args()

    content = __read_csv(csv_file=args.csv)
    for row in content:
        policy = __create_policy(policy_type=args.policy_type, owner=args.owner, data=row)
        print(policy)
        __publish_policy(conn=args.rest_conn, ledger_conn=args.ledger_conn, policy=policy)


if __name__ == '__main__':
    main()