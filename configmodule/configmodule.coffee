configmodule = {name: "configmodule", uimodule: false}
########################################################
log = (arg) ->
    if adminModules.debugmodule.modulesToDebug["configmodule"]?  then console.log "[configmodule]: " + arg
    return

########################################################
configmodule.initialize = () ->
    log "configmodule.initialize"
    return    

#region exposedProperties
configmodule.sServerURL = 'https://localhost:6969'
#endregion

export default configmodule
