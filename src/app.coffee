{@app} = require('zappajs') 5671, ->
    @configure =>
      @use 'bodyParser', 'methodOverride', @app.router, 'static'
      @set 'basepath': '/v1.0'

    @configure
      development: => @use errorHandler: {dumpExceptions: on, showStack: on}
      production: => @use 'errorHandler'

    @enable 'serve jquery', 'minify'

    pv = require('./provisioner')

    @post '/provision': ->       
        console.log "post provision vm received" + JSON.stringify @body        
        pv.create @body, (res) =>
            console.log "post provision response" + JSON.stringify res
            @send res    

    @get '/provison/:id': ->
        console.log " get provison id received" 
        pv.list (res) =>
            console.log "get provision response " + res
            @send res  
