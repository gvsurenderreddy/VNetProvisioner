{@app} = require('zappajs') 5681, ->
    bp = require 'body-parser'
    @use bp.urlencoded extended:false
    @use bp.json()

    pv = require('./provisioner')
    
    pvobjs = {}

    @get '/provision/:id': ->
        console.log " get provison id received" 
        pv.get @params.id, (res) =>
            console.log "get provision id response " + res
            @send res    

    @post '/provision': ->       
        console.log "post provision vm received" + JSON.stringify @body        
        pv.create @body, (res) =>
            console.log "post provision response" + JSON.stringify res
            @send res    

    @get '/provision': ->       
        console.log "post provision vm received" + JSON.stringify @body        
        pv.list (res) =>
            console.log "get provision response" + JSON.stringify res
            @send res  

     @get '/collect/:id/stats': ->
        console.log " get provison stats received ----"  + @params.id
        pv.stats @params.id, (res) =>
            console.log "get provision stats response " + JSON.stringify res
            @send res  


    #service specific functions
    @get '/provision/:pid/service/:sid': ->
        console.log " get service provision id received" 
        pv.serviceget @params.pid, @params.sid, (res) =>
            console.log "get provision id response " + res

            #Todo
            #Merge the  @body in to the Services array using fmerge
            
            return @send res    
        return "Error"

    @get '/device/:pid/service': ->
    @get '/device/:pid/service/:id': ->


