{@app} = require('zappajs') 5671, ->
    @configure =>
      @use 'bodyParser', 'methodOverride', @app.router, 'static'
      @set 'basepath': '/v1.0'

    @configure
      development: => @use errorHandler: {dumpExceptions: on, showStack: on}
      production: => @use 'errorHandler'

    @enable 'serve jquery', 'minify'

    pv = require('./provisioner')


    @get '/provision/:id': ->
        console.log " get provison id received" 
        pv.get @params.id, (res) =>
            console.log "get provision id response " + res
            @send res  

    @get '/provision/:id/stats': ->
        console.log " get provison stats received ----"  + @params.id
        pv.stats @params.id, (res) =>
            console.log "get provision stats response " + JSON.stringify res
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
