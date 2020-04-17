mustachekeysmodule = {name: "mustachekeysmodule"}
############################################################
#region printLogFunctions
log = (arg) ->
    if adminModules.debugmodule.modulesToDebug["mustachekeysmodule"]?  then console.log "[mustachekeysmodule]: " + arg
    return
ostr = (obj) -> JSON.stringify(obj, null, 4)
olog = (obj) -> log "\n" + ostr(obj)
print = (arg) -> console.log(arg)
#endregion

############################################################
mustachekeysmodule.initialize = () ->
    log "mustachekeysmodule.initialize"
    return

############################################################
createNextLevelObject = (contentObject) ->
    if Array.isArray(contentObject) then return []
    else return {}

handleNextLevel = (prefix, mustacheObject, thisContent) ->
    nextLevelKeys = Object.keys(thisContent)
    nextPrefix = ""
    for key in nextLevelKeys
        nextPrefix = prefix+"."+key
        if typeof thisContent[key] != "string"
            mustacheObject[key] = createNextLevelObject(thisContent[key])
            handleNextLevel(nextPrefix, mustacheObject[key], thisContent[key])
        else mustacheObject[key] = "{{{"+nextPrefix+"}}}" 
    return

############################################################
mustachekeysmodule.createMustacheKeys = ->
    log "mustachekeysmodule.createMustacheKeys"
    topLevelKeys = Object.keys(pwaContent)
    
    mustacheKeys = {}
    for key in topLevelKeys
        if typeof pwaContent[key] != "string"
            mustacheKeys[key] = createNextLevelObject(pwaContent[key])
            handleNextLevel(key, mustacheKeys[key], pwaContent[key]) 
        else mustacheKeys[key] = "{{{"+key+"}}}"

    global.pwaMustacheKeymap = mustacheKeys
    return
    
module.exports = mustachekeysmodule