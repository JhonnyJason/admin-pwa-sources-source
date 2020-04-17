listmanagementmodule = {name: "listmanagementmodule"}
############################################################
#region printLogFunctions
log = (arg) ->
    if adminModules.debugmodule.modulesToDebug["listmanagementmodule"]?  then console.log "[listmanagementmodule]: " + arg
    return
ostr = (obj) -> JSON.stringify(obj, null, 4)
olog = (obj) -> log "\n" + ostr(obj)
print = (arg) -> console.log(arg)
#endregion

############################################################
listmanagementmodule.initialize = () ->
    log "listmanagementmodule.initialize"
    return
    
module.exports = listmanagementmodule