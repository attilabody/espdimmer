local module = {}

module.SSID = "iotwifi"
module.PWD = "iotpassword"

module.HOST = "broker.example.com"
module.PORT = 1883
module.ID = node.chipid()

module.ENDPOINT = "nodemcu/"
return module
