StormRegistry = require 'stormregistry'
StormData = require 'stormdata'
util = require('util')
request = require('request-json');
extend = require('util')._extend
ip = require 'ip'
async = require 'async'

class quaggaService
    constructor: (@url, ifmap)->
        console.log "quaggaservice url is "+ @url
        console.log "quaggaservice ifmap is "+ JSON.stringify ifmap
        zebraConfig =
            "hostname":"zebra",
            "password": "zebra",
            "enable password":"password",
            "log file":"/var/log/quagga/ospfd.log debugging",
            "interfaces":[]
            "iproutes":[] 
        ospfdConfig =
            "hostname":"ospf",
            "password": "ospf",
            "enable password":"ospf",
            "log file":"/var/log/quagga/ospfd.log debugging",
            "protocol":
                "router":"ospf",
                "networks":[]

        ripdConfig =
            "hostname":"rip",
            "password": "rip",
            "enable password":"rip",
            "log file":"/var/log/quagga/ripd.log debugging",
            "protocol":
                "router":"rip",
                "networks":[]

        #process ifmap and updata zebraconfig
        ifarray = []
        ospfnwarray = []
        ripdnwarray = []
        for i in ifmap
            #if i.type is not "mgmt"
            unless i.type is "mgmt" 
                ifarray.push 
                    "interface" : i.ifname
                    "description" : i.brname
                    # To : interface.netmask to be converted as prefix, currenty hardcoding
                    "ip address" : "#{i.ipaddress}/30"  
                    "bandwidth" : 100000
                ospfnwarray.push
                    "network" : "#{i.ipaddress}/30 area 0"  
                ripdnwarray.push
                    "network" : i.ifname
        console.log "zebra ifarray array" + JSON.stringify ifarray
        console.log "ospfnwarray  "+ JSON.stringify ospfnwarray
        console.log "ripwarray  "+ JSON.stringify ripdnwarray

        zebraConfig.interfaces = ifarray
        ospfdConfig.protocol.networks = ospfnwarray
        ripdConfig.protocol.networks = ripdnwarray
        #process ifmap and update ospfd config

        client = request.newClient(@url)
        client.post "/quagga/zebra", zebraConfig,(err, res, body) =>
            util.log "post zebra Err  " + err if err?
            util.log "post zebra result body  " + JSON.stringify body if body?
            util.log "post zebra status code res statuscode" + res.statusCode if res?.statusCode?
            

        client.post "/quagga/ospfd", ospfdConfig,(err, res, body) =>
            util.log "post ospfd Err  " + err if err?
            util.log "post ospfd result body  " + JSON.stringify body if body?
            util.log "post ospfd status code res statuscode" + res.statusCode if res?.statusCode?

        client.post "/quagga/ripd", ripdConfig,(err, res, body) =>
            util.log "post ripd Err  " + err if err?
            util.log "post ripd result body  " + JSON.stringify body if body?
            util.log "post ripd status code res statuscode" + res.statusCode if res?.statusCode?                

module.exports = quaggaService