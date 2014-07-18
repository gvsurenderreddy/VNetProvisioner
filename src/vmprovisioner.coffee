
class vmprovision
    findmgmtip: ()->
        for i in @vmdata.ifmap
            if i.type is "mgmt"
                @mgmtip = i.ipaddress
                console.log "mgmtip" + @mgmtip

    vmstatus:()->
        #ping the managent ip

        #do /status from stormflash to check the reachability

        @rechable = true
    provisionQuagga:()->
        




    constructor : (@vmdata) ->
        util.log "intput" + JSON.stringify vmdata

        findmgmtip()        
        return null unless @mgmtip?

        #check the reachabiltiy by querying the status
        vmstatus()
        return null unless @rechable?


        provisionQuagga()
        #start provisioning
        for service in vmdata.Services
            switch service.name
                when 'quagga'
                    result = provisionQuagga()
