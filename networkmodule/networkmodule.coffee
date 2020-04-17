networkmodule = {name: "networkmodule", uimodule: false}
############################################################
log = (arg) ->
    if adminModules.debugmodule.modulesToDebug["networkmodule"]?  then console.log "[networkmodule]: " + arg
    return

############################################################
#region internalVariables
sServerURL = ""
uploadIndicator = null
#endregion internal variables

############################################################
networkmodule.initialize = () ->
    log "networkmodule.initialize"
    sServerURL = adminModules.configmodule.sServerURL
    return
    
############################################################
#region internalFunctions
postData = (url, data) ->
    options =
        method: 'POST'
        credentials: 'omit'
        body: JSON.stringify(data)
        headers:
            'Content-Type': 'application/json'

    response = await fetch(url, options)
    if response.status == 403 then throw new Error("Unauthorized!")
    return response.json()

postFormData = (url, formData) ->
    options = 
        method: "POST"
        credentials: "omit"
        body: formData
    response = await fetch(url, options)
    if response.status == 403 then throw new Error("Unauthorized!")
    if response.status != 200 then throw new Error("Unexpected Response Status!")
    return

requestService = (url, data, successCallback, failCallback) ->
    if data then console.log 'sending data' + JSON.stringify(data)
    request = new XMLHttpRequest
    request.open 'POST', url
    request.setRequestHeader 'Content-Type', 'application/json'
    if data 
        request.send JSON.stringify(data)
    else 
        request.send()

    request.onreadystatechange = ->
        if request.readyState == 4
            response = {}
            if request.response and request.status == 200
                try 
                    response = JSON.parse(request.response)
                    successCallback(response)
                catch err then failCallback(request)
            if request.status != 200
                failCallback request
        else
            if request.status != 200
                failCallback request
        return
    return


#endregion 

############################################################
#region exposed functions
networkmodule.uploadImage = (formData) ->
    log "networkmodule.uploadImage"
    url = sServerURL + "/uploadImage"
    return postFormData url, formData

networkmodule.scicall = (route, data) ->
    log "networkmodule.scicall"
    url = sServerURL + "/" + route
    return postData(url, data)

networkmodule.requestBackendService = (route, data, successCallback, failCallback) ->
    requestService sServerURL + "/" + route, data, successCallback, failCallback
    return

#endregion

export default networkmodule