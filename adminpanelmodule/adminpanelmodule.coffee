adminpanelmodule = {name: "adminpanelmodule"}
############################################################
#region printLogFunctions
log = (arg) ->
    if adminModules.debugmodule.modulesToDebug["adminpanelmodule"]?  then console.log "[adminpanelmodule]: " + arg
    return
ostr = (obj) -> JSON.stringify(obj, null, 4)
olog = (obj) -> log "\n" + ostr(obj)
print = (arg) -> console.log(arg)
#endregion

############################################################
uiState = null

############################################################
adminpanelmodule.initialize = () ->
    log "adminpanelmodule.initialize"
    uiState = adminModules.uistatemodule

    adminPanel.addEventListener("load", adminPanelLoaded)
    adminPanelVisibilityButton.addEventListener("click", panelVisibilityButtonClicked) 
    applyPanelState()
    return
    
############################################################
#region eventListeners
panelVisibilityButtonClicked = -> #togglePanelVisibility
    log "panelVisibilityButtonClicked"
    if(uiState.adminPanelVisible()) then uiState.adminPanelVisible false
    else uiState.adminPanelVisible true

    uiState.save()
    applyPanelState()
    return

adminPanelLoaded = ->
    log "adminPanelLoaded"
    return

#endregion

############################################################
applyPanelState = ->
    log "applyPanelState"
    uiState.print()
    log uiState.adminPanelVisible()
    if uiState.adminPanelVisible()
        log "adminPanelVisible was true"
        adminPanel.classList.remove("hidden")
        adminPanelVisibilityButton.classList.remove("hidden-panel")
    else
        log "adminPanelVisible was false"
        adminPanel.classList.add("hidden")
        adminPanelVisibilityButton.classList.add("hidden-panel")
    return

############################################################
adminpanelmodule.attachPanelToBody = (body) ->
    log "adminpanelmodule.attachPanelToBody"
    body.appendChild adminPanel 
    body.appendChild adminPanelVisibilityButton 
    return

module.exports = adminpanelmodule