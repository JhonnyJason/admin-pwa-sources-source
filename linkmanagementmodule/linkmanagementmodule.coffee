linkmanagementmodule = {name: "linkmanagementmodule"}
############################################################
#region printLogFunctions
log = (arg) ->
    if adminModules.debugmodule.modulesToDebug["linkmanagementmodule"]?  then console.log "[linkmanagementmodule]: " + arg
    return
ostr = (obj) -> JSON.stringify(obj, null, 4)
olog = (obj) -> log "\n" + ostr(obj)
print = (arg) -> console.log(arg)
#endregion

############################################################
linkmanagementmodule.initialize = () ->
    log "linkmanagementmodule.initialize"
    return
    
module.exports = linkmanagementmodule