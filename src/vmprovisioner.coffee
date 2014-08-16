
StormRegistry = require 'stormregistry'
StormData = require 'stormdata'
util = require('util')
request = require('request-json');
extend = require('util')._extend
ip = require 'ip'
async = require 'async'

QuaggaService = require './quaggaservice'


class vmprovision
    constructor : (vmdata) ->
        @uuid = vmdata.id
        @linkstats = []
        @routestats = []
        @osstatus = []
        @vmdata = vmdata
        @uuid = vmdata.id
        @reachable = false
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
        util.log "vmstatus is called"
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
            
    #refactoring required
    statistics: (callback) ->
        #async parallel to be used here and call one by one
        util.log "statistics called"
        @getLinkStats (result) =>
            @getRouteStats (result1) =>                
                callback 
                    "linkstats" : result
                    "routestats" : result1


    # provision steps
    # 1. mgmt ip is required to provision
    # ??

    provision: (callback) ->  
        unless @mgmtip?                                      
            return callback 
                id : @uuid
                status : "provision-failed"
                reason : "mgmt ip not available"

        
        @reachable = false 
        #currently reachability check is happening infinetlye. this needs to be changed in to fixed iterations
        async.until(
            ()=>
                return @reachable 
            (repeat)=>                
                @vmstatus ()->
                setTimeout(repeat, 5000);
            (err)=>
                util.log "over"
                callback
        )

        #if @reachable is false
        #    return callback 
        #        id : @uuid
        #        status : "provision-failed"
        #        reason : "failed to talk to stormflash"

        console.log "Start Provisioning the Services " + JSON.stringify @vmdata.Services

        #start provisioning
        for service in @vmdata.Services
            console.log "service" + JSON.stringify service
            switch service.name
                when 'quagga'   
                    quaggaobj = new QuaggaService @url, @vmdata.ifmap
                #when 'openvpn'
                #    console.log "openvpns service"
                #    #Todo
                #when 'strongswan'
                #    console.log "strongswan service"
                #    #Todo
                #when 'iptables'
                #    console.log "iptables service"
                #    #Todo
                #when 'snort'
                #    console.log "snort service"
                #    #Todo
                #when 'iproute2'
                #    console.log "iproute2 service"
                
                #    #Todo

        callback 
            id : @uuid
            status : "provisioned"


module.exports = vmprovision
