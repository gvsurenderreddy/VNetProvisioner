StormRegistry = require 'stormregistry'
StormData = require 'stormdata'
util = require('util')
request = require('request-json');
extend = require('util')._extend
ip = require 'ip'
async = require 'async'

vmprovision = require './vmprovisioner'

class provisionerData extends StormData
	schema =        
        name: "node"
        type: "object"        
        properties:
            id : {type:"string", required:true}
            name: {type:"string", required:true}
            type: {type:"string", required:true}
            Services:
                type: "array"
                required: true
                items:
                    type: "object"
                    required: true                                    
                    properties:
                        name:           {"type":"string", "required":true}                                        
                        #enabled:        {"type":"boolean", "required":false}                                
                        config: 
                            type: "object"
            ifmap:
                type: "array"
                items:
                    type: "object"
                    name: "ifmapp"
                    properties:
                        ifname: {type:"string","required":true}
                        hwAddress: {type:"string","required":true}
                        brname: {type:"string","required":false}
                        ipaddress:{type:"string","required":true}
                        netmask:{type:"string","required":true}
                        gateway:{type:"string","required":false}
                        type:{type:"string","required":true}
                        config : 
                            type: "object"
                            properties:
                                bandwidth:           {"type":"string", "required":true}                                        
                                latency:        {"type":"string", "required":true}  
                                jitter:        {"type":"string", "required":true}  
                                pktloss:        {"type":"string", "required":true}  

    constructor: (id, data) ->
        super id, data, schema

class provisionerRegistry extends StormRegistry
    constructor: (filename) ->
        @on 'load', (key,val) ->
            console.log "restoring #{key} with:",val
            entry = new provisionerData key,val
            if entry?
                entry.saved = true
                @add entry

        @on 'removed', (entry) ->
            entry.destructor() if entry.destructor?

        super filename

    add: (data) ->
        return unless data instanceof provisionerData
        entry = super data.id, data

    update: (data) ->        
        super data.id, data    

    get: (key) ->
        entry = super key
        return unless entry?

        if entry.data? and entry.data instanceof provisionerData
            entry.data.id = entry.id
            entry.data
        else
            entry



class Provisioner

    constructor :(filename) ->
        @vmpobj = []
        @registry = new provisionerRegistry filename

        @registry.on 'load',(key,val) ->
            util.log "Loading key #{key} with val #{val}"   

    list : (callback) ->
        callback @registry.list()

    get: (data, callback) ->
        callback @registry.get data

    create: (data,callback) ->
        try         
            pvdata = new provisionerData(data.id, data )
        catch err
            util.log "invalid schema" + err
            return callback new Error "Invalid Input "  
        finally            
            @registry.add pvdata
            #util.log JSON.stringify pvdata.data
            vmp = new vmprovision pvdata.data
            @vmpobj.push vmp
            vmp.provision (res)=>                
                callback res

    #API for collecting the device link statistics
    stats: (data, callback) ->
        obj = @getobjbyid(data)
        if obj?
            obj.statistics (res)=>
                console.log "statistics output " + JSON.stringify   res
                callback res
        else                
            return callback new Error "Unknown Device ID"


    #API for collecting the device link statistics
    serviceget: (provisionerid, serviceid, callback) ->
        obj = @getobjbyid(provisionerid)
        if obj?
            #obj.statistics (res)=>
            obj.getService serviceid , (res) =>
                console.log "service  output " + JSON.stringify   res
                callback res
        else                
            return callback new Error "Unknown Device ID"


    getobjbyid:(id) ->
        for obj in @vmpobj
            util.log "vmpobj" + obj.uuid
            if  obj.uuid is id
                util.log "getObjbyid found " + obj.uuid
                return obj
        return null



module.exports = new Provisioner '/tmp/provisioner.db'
