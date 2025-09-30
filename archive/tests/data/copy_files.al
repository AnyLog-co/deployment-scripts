#-----------------------------------------------------------------------------------------------------------------------
# The following inserts 20,000 rows into 2 tables by moving the data from the !test_dir to the !watch_dir. This
# means data can be stored into a single Operator (cluster) by executing the script through the operator node, or
# distributed among Operators via the Publisher.
#
# About the data:
#   trig_data - 10,000 rows with date range between:
#       {
#           "value": 0.5235987755982988,
#           "sin": 0.49999999999999994,
#           "cos": 0.8660254037844387,
#           "tan": 0.5773502691896256,
#           "timestamp": "2023-02-15T20:08:12.087062Z"
#       }
#   performance - 10,000 rows with date range between:
#       {
#            "value": -1.2246467991473532e-16,
#            "timestamp": "2022-08-27T15:50:12.283323Z"
#        }
#   percentagecpu_sensor
#       {
#           "device_name": "ADVA FSP3000R7",
#           "parentelement": "62e71893-92e0-11e9-b465-d4856454f4ba",
#           "webid": "F1AbEfLbwwL8F6EiShvDV-QH70AkxjnYuCS6RG0ZdSFZFT0ugnMRtEzvxdFojNpadLPwI4gWE9NUEFTUy1MSVRTTFxMSVRTQU5MRUFORFJPXDc3NyBEQVZJU1xQT1AgUk9PTVxBRFZBIEZTUDMwMDBSN3xQSU5H",
#           "value": 6.87,
#           "timestamp": "2023-03-14T17:39:32.892623Z"
#       }
#   ping_sensor
#       {
#           "device_name": "ADVA FSP3000R7",
#           "parentelement": "62e71893-92e0-11e9-b465-d4856454f4ba",
#           "webid": "F1AbEfLbwwL8F6EiShvDV-QH70AkxjnYuCS6RG0ZdSFZFT0ugnMRtEzvxdFojNpadLPwI4gWE9NUEFTUy1MSVRTTFxMSVRTQU5MRUFORFJPXDc3NyBEQVZJU1xQT1AgUk9PTVxBRFZBIEZTUDMwMDBSN3xQSU5H",
#           "value": 3.51,
#           "timestamp": "2023-03-14T17:39:21.592907Z"
#       }
#-----------------------------------------------------------------------------------------------------------------------
# process !data_dir/test/data/copy_files.al

if not !test_db then set test_db = test

file copy !test_dir/data/test.percentagecpu_sensor.1677448612.json !watch_dir/test.percentagecpu_sensor.1677448612.json
file copy !test_dir/data/test.percentagecpu_sensor.1677854452.json !watch_dir/test.percentagecpu_sensor.1677854452.json
file copy !test_dir/data/test.percentagecpu_sensor.1678117791.json !watch_dir/test.percentagecpu_sensor.1678117791.json
file copy !test_dir/data/test.percentagecpu_sensor.1679760291.json !watch_dir/test.percentagecpu_sensor.1679760291.json
file copy !test_dir/data/test.percentagecpu_sensor.1680451311.json !watch_dir/test.percentagecpu_sensor.1680451311.json

file copy !test_dir/data/test.ping_sensor.1676581786.json !watch_dir/test.ping_sensor.1676581786.json
file copy !test_dir/data/test.ping_sensor.1677227566.json !watch_dir/test.ping_sensor.1677227566.json 
file copy !test_dir/data/test.ping_sensor.1680507167.json !watch_dir/test.ping_sensor.1680507167.json
file copy !test_dir/data/test.ping_sensor.1680562547.json !watch_dir/test.ping_sensor.1680562547.json 
file copy !test_dir/data/test.ping_sensor.1681458826.json !watch_dir/test.ping_sensor.1681458826.json

file copy !test_dir/data/test.image.1679110709.json !watch_dir/test.image.1679110709.json
file copy !test_dir/data/test.image.1679110710.json !watch_dir/test.image.1679110710.json
file copy !test_dir/data/test.image.1679110863.json !watch_dir/test.image.1679110863.json
file copy !test_dir/data/test.image.1879110709.json !watch_dir/test.image.1879110709.json
file copy !test_dir/data/test.image.3679110709.json !watch_dir/test.image.3679110709.json

file copy !test_dir/data/test.video.1678111908.json !watch_dir/test.video.1678111908.json
file copy !test_dir/data/test.video.1679111893.json !watch_dir/test.video.1679111893.json
file copy !test_dir/data/test.video.1679111898.json !watch_dir/test.video.1679111898.json
file copy !test_dir/data/test.video.1679111908.json !watch_dir/test.video.1679111908.json
file copy !test_dir/data/test.video.1879111893.json !watch_dir/test.video.1879111893.json
