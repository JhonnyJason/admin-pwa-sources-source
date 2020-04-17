uistatemodule = {name: "uistatemodule"}
############################################################
#region printLogFunctions
log = (arg) ->
    if adminModules.debugmodule.modulesToDebug["uistatemodule"]?  then console.log "[uistatemodule]: " + arg
    return
ostr = (obj) -> JSON.stringify(obj, null, 4)
olog = (obj) -> log "\n" + ostr(obj)
print = (arg) -> console.log(arg)
#endregion

############################################################
defaultUIState =
    adminPanelVisible: true
    bigPanelVisible: false
    visibleEditables: false
    activeTab: "lists" # "images" || "links"
    activeImageEdit: ""
    activeListEdit: ""
    activeLinkEdit: ""
    loginButtonVisible: true
    discardButtonState: "hidden" # "active" || ""
    makeVisibleButtonState: "hidden" # "active" || ""
    publishButtonState: "hidden" # "active" || ""
    bigPanelButtonState: "hidden" # "active" || ""

############################################################
uiState = localStorage.getItem("admin-ui-state")
if uiState then uiState = JSON.parse(uiState)
else uiState = defaultUIState
# for resetting
# uiState = defaultUIState

setGetFunctionFor = (key) ->
    return (value) ->
        if value? then uiState[key] = value
        return uiState[key]

############################################################
for key,state of uiState
    uistatemodule[key] = setGetFunctionFor(key)

############################################################
uistatemodule.initialize = () ->
    log "uistatemodule.initialize"
    return

############################################################
uistatemodule.save = ->
    log "save"
    saveString = JSON.stringify(uiState)
    localStorage.setItem("admin-ui-state", saveString)
    return

uistatemodule.print = -> olog uiState

module.exports = uistatemodule