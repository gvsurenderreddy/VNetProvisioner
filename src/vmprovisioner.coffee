
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
            util.log "post zebra result body  " + JSON.stringify body if body?
            util.log "post zebra status code res statuscode" + res.statusCode if res.statusCode?
            

        client.post "/quagga/ospfd", ospfdConfig,(err, res, body) =>
            util.log "post ospfd result body  " + JSON.stringify body if body?
            util.log "post ospfd status code res statuscode" + res.statusCode if res.statusCode?

        client.post "/quagga/ripd", ripdConfig,(err, res, body) =>
            util.log "post ripd result body  " + JSON.stringify body if body?
            util.log "post ripd status code res statuscode" + res.statusCode if res.statusCode?
                  



class vmprovision
    constructor : (vmdata) ->
        @uuid = vmdata.id
        @linkstats = []
        @routestats = []
        @osstatus = []
        @vmdata = vmdata
        @uuid = vmdata.id

        util.log "intput vmdata" + JSON.stringify @vmdata
        @findmgmtip() 

    findmgmtip: ()->
        for i in @vmdata.ifmap
            if i.type is "mgmt"
                @mgmtip = i.ipaddress
                console.log "mgmtip" + @mgmtip

    getLinkStats: (callback)->        
        @url= "http://#{@mgmtip}:5000"        
        client = request.newClient(@url)
        client.get "/netstats/link", (err, res, body) =>            
            if res?
                util.log "get result status code res statuscode" + res.statusCode if res.statusCode?            
                @linkstats = body if body?
                util.log "linkstats "+ JSON.stringify @linkstats
                callback @linkstats

    getRouteStats: (callback)->        
        @url= "http://#{@mgmtip}:5000"        
        client = request.newClient(@url)
        client.get "/netstats/route", (err, res, body) =>            
            if res?
                util.log "get result status code res statuscode" + res.statusCode if res.statusCode?            
                @routestats = body if body?
                callback @routestats
            
    vmstatus: (callback) ->                
        @url= "http://#{@mgmtip}:5000"        
        client = request.newClient(@url)
        client.get "/status", (err, res, body) =>            
            if res?
                util.log "get result status code res statuscode" + res.statusCode if res.statusCode?
                #check the response before say reachable
                util.log "inside res condition"
                @reachable = true 
                @osstatus = body if body?
                callback  
            else
                @reachable = false 
                callback 
            
    statistics: (callback) ->
        #async parallel to be used here and call one by one
        util.log "statistics called"
        @getLinkStats (result) =>
            @getRouteStats (result1) =>                
                callback 
                    "linkstats" : result
                    "routestats" : result1
                    
        #    @getRouteStats () =>               
        #            callback
        #                "osstats" :  @osstatus
        #                "linkstats" : @linkstats
        #                "routestats" : @routestats

    provision: (callback) ->  
        unless @mgmtip?                                      
            return callback null 

        @reachable = false
        async.until(
            ()=>
                return @reachable
            (repeat)=>
                @vmstatus () =>
                setTimeout(repeat, 5000);
            (err)=>
                util.log "over"
                callback
        )

        console.log "Services " + JSON.stringify @vmdata.Services
        #start provisioning
        for service in @vmdata.Services
            console.log "service" + JSON.stringify service
            switch service.name
                when 'quagga'   
                    quaggaobj = new quaggaService @url, @vmdata.ifmap
        callback (true)


module.exports = vmprovision
