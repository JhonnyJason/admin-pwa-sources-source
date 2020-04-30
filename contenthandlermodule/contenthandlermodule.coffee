contenthandlermodule = {name: "contenthandlermodule"}
############################################################
#region printLogFunctions
log = (arg) ->
    if adminModules.debugmodule.modulesToDebug["contenthandlermodule"]?  then console.log "[contenthandlermodule]: " + arg
    return
ostr = (obj) -> JSON.stringify(obj, null, 4)
olog = (obj) -> log "\n" + ostr(obj)
print = (arg) -> console.log(arg)
#endregion

############################################################
#region modulesFromEnvironment
hasher = require "crypto-hash"

############################################################
appState = null
network = null

#endregion

############################################################
currentOriginal = pwaContent
currentContent = JSON.parse(JSON.stringify(currentOriginal))

############################################################
contenthandlermodule.initialize = () ->
    log "contenthandlermodule.initialize"
    appState = adminModules.appstatemodule
    network = adminModules.networkmodule
    return
    
############################################################
requestCurrentOriginal = ->
    log "requestCurrentOriginal"
    token = appState.token()
    langTag = pwaContent.languageTag
    path = window.location.pathname
    documentName = path.split("/").pop()
    data = {langTag, documentName, token}
    try
        originalContent = await network.scicall("getOriginalContent", data)
        currentOriginal = originalContent
    catch err
        log err
    return

calculateOriginalHash = ->
    log "calculateOriginalHash"
    contentString = JSON.stringify(pwaContent)
    return await hasher.sha1(contentString)

reflectEdit = (key, content) ->
    log "reflectEdit"
    tokens = key.split(".")
    log tokens
    console.log "- - - reflect Edit of: " + key
    console.log ostr content

    contentObject = currentContent
    index = 0
    while index < (tokens.length - 1)
        contentObject = contentObject[tokens[index]]
        if !contentObject then return
        index++
    contentObject[tokens[index]] = content
    return

############################################################
contenthandlermodule.prepareOriginal = (remoteHash) ->
    log "contenthandlermodule.prepareOriginal"
    originalHash = await calculateOriginalHash()
    # log originalHash
    # log remoteHash
    if remoteHash == originalHash then currentOriginal = pwaContent
    else await requestCurrentOriginal()
    return

contenthandlermodule.reflectEdits = (edits) ->
    log "contenthandlermodule.reflectEdits"
    currentContent = JSON.parse(JSON.stringify(currentOriginal))
    # reflectEdit(key,content) for key,content of edits
    
    ## apply first the structural updats then the simple text updates.
    reflectEdit(key,content) for key,content of edits when Array.isArray(content)
    reflectEdit(key,content) for key,content of edits when !Array.isArray(content)
    return

contenthandlermodule.content = -> currentContent

contenthandlermodule.reflectEdit = (key, content) -> reflectEdit(key, content)

module.exports = contenthandlermodule