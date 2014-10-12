StormRegistry = require 'stormregistry'
StormData = require 'stormdata'
util = require('util')
request = require('request-json');
extend = require('util')._extend
ip = require 'ip'
async = require 'async'
uuid = require('node-uuid')

class quaggaService

    start: ()->
        client = request.newClient(@url)
        client.post "/quagga/zebra", @config.zebra,(err, res, body) =>
            util.log "post zebra Err  " + err if err?
            util.log "post zebra result body  " + JSON.stringify body if body?
            util.log "post zebra status code res statuscode" + res.statusCode if res?.statusCode?
            
        client.post "/quagga/ospfd", @config.ospfd,(err, res, body) =>
            util.log "post ospfd Err  " + err if err?
            util.log "post ospfd result body  " + JSON.stringify body if body?
            util.log "post ospfd status code res statuscode" + res.statusCode if res?.statusCode?

    stop: ()->    
    update: ()->
    getuuid:() -> 
        return @id
    getService:(callback) ->
        client = request.newClient(@url)
        client.get "/quagga/zebra",(err, res, body) =>
            util.log "get zebra Err  " + err if err?
            util.log "get zebra result body  " + JSON.stringify body if body?
            util.log "get zebra status code res statuscode" + res.statusCode if res?.statusCode?
            callback res

    constructor: (@url, ifmap)->
        console.log "quaggaservice url is "+ @url
        console.log "quaggaservice ifmap is "+ JSON.stringify ifmap        
        @id = uuid.v4()
        @config = 
            id : @id
            zebra : null
            ospfd : null
            ripd : null

        #@zebraConfig =
        @config.zebra =
            "hostname":"zebra",
            "password": "zebra",
            "enable password":"password",
            "log file":"/var/log/zebra.log debugging",
            "interfaces":[]
            "iproutes":[] 
        #@ospfdConfig =
        @config.ospfd =
            "hostname":"ospf",
            "password": "ospf",
            "enable password":"ospf",
            "log file":"/var/log/ospfd.log debugging",
            "protocol":
                "router":"ospf",
                "networks":[]

        #@ripdConfig =
        @config.ripd =
            "hostname":"rip",
            "password": "rip",
            "enable password":"rip",
            "log file":"/var/log/ripd.log debugging",
            "protocol":
                "router":"rip",
                "networks":[]

        #process ifmap and updata zebraconfig
        ifarray = []
        ospfnwarray = []
        ripdnwarray = []

        for i in ifmap
            #if i.type is not "mgmt"
            if i.type is "wan" 
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

        #@zebraConfig.interfaces = ifarray
        @config.zebra.interfaces = ifarray
        #@ospfdConfig.protocol.networks = ospfnwarray
        @config.ospfd.protocol.networks = ospfnwarray
        #@ripdConfig.protocol.networks = ripdnwarray
        @config.ripd.protocol.networks = ripdnwarray
        #process ifmap and update ospfd config

module.exports = quaggaService
