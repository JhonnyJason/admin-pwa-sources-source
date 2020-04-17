tabspanelmodule = {name: "tabspanelmodule"}
############################################################
#region printLogFunctions
log = (arg) ->
    if adminModules.debugmodule.modulesToDebug["tabspanelmodule"]?  then console.log "[tabspanelmodule]: " + arg
    return
ostr = (obj) -> JSON.stringify(obj, null, 4)
olog = (obj) -> log "\n" + ostr(obj)
print = (arg) -> console.log(arg)
#endregion

############################################################
tabspanelmodule.initialize = () ->
    log "tabspanelmodule.initialize"
    return
    
module.exports = tabspanelmodule