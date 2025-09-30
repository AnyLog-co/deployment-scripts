# Testing 

* [Test Suite](https://github.com/AnyLog-co/documentation/blob/master/test%20suites.md)

## How to Run
1. Declare a test database on the operator node(s)
```anylog 
create database test where type=[sqlite | psql] [and host = 127.0.0.1 and port=5432 and user=admin and password=passwd] 
```

2. Create A new cluster(s) for test database 
```anylog
process !test_dir/data/create_cluster.al
```

3. Initiate a _Publisher_ node if doesn't exist - [directions for deploying node](https://github.com/AnyLog-co/documentation/blob/master/deployments/deploying_node.md)

4. On the _Publisher_ node execute data insertion - Publisher node will distribute the data among the operator nodes 
```anylog
AL > process !test_dir/data/copy_files.al 
```

5. [Execute tests](#execute-tests)

## Pytest 
* How to create you're own test(s) 
```python3
 @pytest.mark.usefixtures("pass_parameters")
class TestClass(unittest.TestCase):
    @classmethod
    def setup_class(cls):
        cls.base_query = f"sql test format=json and stat=false and include=(percentagecpu_sensor) "

    def test_code(self):
        """
        Code to be used for testing 
        """
        assert True 
```

* How to execute tests
```shell
pytest $HOME/AnyLog-Network/test/pytests/test_multi_table_aggregate_functions.py \
  -xs -vv \
  --conn ${USER}:${PASSWORD}:${REST_CONN} \
  --destination ${REMOTE_TCP_CONN} \
  --timeout ${REST_TIMEOUT} \  
```
