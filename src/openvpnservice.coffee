StormRegistry = require 'stormregistry'
StormData = require 'stormdata'
util = require('util')
request = require('request-json');
extend = require('util')._extend
ip = require 'ip'
async = require 'async'

class openvpnService

    start: ()->
        if @openvpnServerConfig?
            client = request.newClient(@url)
            client.post "/openvpn/server", @openvpnServerConfig,(err, res, body) =>
                util.log "post openvpn server Err  " + err if err?
                util.log "post openvpn result body  " + JSON.stringify body if body?
                util.log "post openvpn status code res statuscode" + res.statusCode if res?.statusCode?
        
    stop: ()->    

    update: ()->

    constructor: (@url,config)->
        console.log "openvpn url is "+ @url        
        @openvpnServerConfig = extend {}, config.server if config?.server?           
        @openvpnClientConfig = extend {}, config.server if config?.client?              
        util.log "openvpnServerConfig " + @openvpnServerConfig
        util.log "openvpnClientConfig " + @openvpnClientConfig

module.exports = openvpnService