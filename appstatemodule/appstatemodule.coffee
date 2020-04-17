appstatemodule = {name: "appstatemodule"}
############################################################
#region printLogFunctions
log = (arg) ->
    if adminModules.debugmodule.modulesToDebug["appstatemodule"]?  then console.log "[appstatemodule]: " + arg
    return
ostr = (obj) -> JSON.stringify(obj, null, 4)
olog = (obj) -> log "\n" + ostr(obj)
print = (arg) -> console.log(arg)
#endregion

############################################################
defaultAppState = 
    isAuthenticated: false
    token: ""
    dirty: false

appState = localStorage.getItem("admin-app-state")
if appState then appState = JSON.parse(appState)
else appState = defaultAppState

############################################################
uiState = null

############################################################
appstatemodule.initialize = () ->
    log "appstatemodule.initialize"
    uiState = adminModules.uistatemodule
    auth = adminModules.authmodule
    return

############################################################
setUIState = ->
    log "setUIState"
    if appState.isAuthenticated
        uiState.loginButtonVisible false
        if appState.dirty then uiState.discardButtonState  "active"
        else uiState.discardButtonState  ""
        if uiState.visibleEditables() then uiState.makeVisibleButtonState "active"
        else uiState.makeVisibleButtonState ""
        if appState.dirty then uiState.publishButtonState "active"
        else uiState.publishButtonState ""
        if uiState.bigPanelVisible() then uiState.bigPanelButtonState "active"
        else uiState.bigPanelButtonState ""
    else
        uiState.loginButtonVisible true
        uiState.bigPanelVisible false
        uiState.discardButtonState  "hidden"
        uiState.makeVisibleButtonState "hidden"
        uiState.publishButtonState "hidden"
        uiState.bigPanelButtonState "hidden"
    return

############################################################
save = ->
    log "save"
    saveString = JSON.stringify(appState)
    localStorage.setItem("admin-app-state", saveString)
    return

saveStates = ->
    log "saveStates"
    save()
    setUIState()
    uiState.save()
    return


############################################################
appstatemodule.setAuthenticated = (token) ->
    log "appstatemodule.setAuthenticated"
    appState.isAuthenticated = true
    appState.token = token
    saveStates()
    return

appstatemodule.setUnauthenticated = ->
    log "appstatemodule.setUnauthenticated"
    appState.isAuthenticated = false
    appState.token = ""
    saveStates()
    return

appstatemodule.setDirty = ->
    log "appstatemodule.setDirty"
    appState.dirty = true
    saveStates()
    return

appstatemodule.setClean = ->
    log "appstatemodule.setClean"
    appState.dirty = false
    saveStates()
    return

############################################################
appstatemodule.token = -> appState.token

module.exports = appstatemodule