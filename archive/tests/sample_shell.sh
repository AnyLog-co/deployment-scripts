#!/bin/bash
# compress data
tar -czvf test/data.tar.gz test/data/

# decompress data
tar -zxvf  test/data.tar.gz -C !test_dir