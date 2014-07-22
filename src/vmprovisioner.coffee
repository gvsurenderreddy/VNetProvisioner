
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
        #process ifmap and updata zebraconfig
        ifarray = []
        ospfnwarray = []
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
        console.log "zebra ifarray array" + JSON.stringify ifarray
        console.log "ospfnwarray  "+ JSON.stringify ospfnwarray

        zebraConfig.interfaces = ifarray
        ospfdConfig.protocol.networks = ospfnwarray
        #process ifmap and update ospfd config



        client = request.newClient(@url)
        client.post "/quagga/zebra", zebraConfig,(err, res, body) =>
            util.log "post zebra result body  " + JSON.stringify body if body?
            util.log "post zebra status code res statuscode" + res.statusCode
            

        client.post "/quagga/ospfd", ospfdConfig,(err, res, body) =>
            util.log "post ospfd result body  " + JSON.stringify body if body?
            util.log "post ospfd status code res statuscode" + res.statusCode
                  



class vmprovision
    findmgmtip: ()->
        for i in @vmdata.ifmap
            if i.type is "mgmt"
                @mgmtip = i.ipaddress
                console.log "mgmtip" + @mgmtip

    vmstatus:(callback)->        #ping the managent ip
        #do /status from stormflash to check the reachability
        
        @url= "http://#{@mgmtip}:5000"
        util.log "url" + @url
        client = request.newClient(@url)
        client.get "/status", (err, res, body) =>
            #util.log "get result body  " + JSON.stringify body if body?
            util.log "get result status code res statuscode" + res.statusCode
            @rechable = true
            callback()


    constructor : (@vmdata) ->
        util.log "intput vmdata" + JSON.stringify @vmdata

        @findmgmtip()        
        return null unless @mgmtip?

        #check the reachabiltiy by querying the status
        @vmstatus ()->
        console.log "Services " + JSON.stringify @vmdata.Services
        #start provisioning
        for service in @vmdata.Services
            console.log "service" + JSON.stringify service
            switch service.name
                when 'quagga'   
                    quaggaobj = new quaggaService @url,vmdata.ifmap


module.exports = vmprovision
