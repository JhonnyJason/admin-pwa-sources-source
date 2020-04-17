bottompanelmodule = {name: "bottompanelmodule"}
############################################################
#region printLogFunctions
log = (arg) ->
    if adminModules.debugmodule.modulesToDebug["bottompanelmodule"]?  then console.log "[bottompanelmodule]: " + arg
    return
ostr = (obj) -> JSON.stringify(obj, null, 4)
olog = (obj) -> log "\n" + ostr(obj)
print = (arg) -> console.log(arg)
#endregion

############################################################
#region modulesFromEnvironment
uiState = null
appState = null
bigpanel = null
auth = null
admin = null
#endregion

#region domconnectFix
## domconnect not working for the buttons
adminLoginButton = null
adminLogoutButton = null
adminDiscardButton = null
adminPublishButton = null
adminMakeVisibleButton = null
adminBigpanelVisibilityButton = null
#endregion

############################################################
spinnerActive = false
currentMessageTimeoutId = 0

############################################################
bottompanelmodule.initialize = () ->
    log "bottompanelmodule.initialize"
    uiState = adminModules.uistatemodule
    appState = adminModules.appstatemodule
    bigpanel = adminModules.bigpanelmodule
    admin = adminModules.adminmodule
    auth = adminModules.authmodule

    #region domconnectFix
    ## domconnect not working for the buttons
    adminLoginButton = document.getElementById("admin-login-button")
    adminLogoutButton = document.getElementById("admin-logout-button")
    adminDiscardButton = document.getElementById("admin-discard-button")
    adminPublishButton = document.getElementById("admin-publish-button")
    adminMakeVisibleButton = document.getElementById("admin-make-visible-button")
    adminBigpanelVisibilityButton = document.getElementById("admin-bigpanel-visibility-button")
    #endregion

    adminLoginButton.addEventListener("click", loginButtonClicked)
    adminLogoutButton.addEventListener("click", logoutButtonClicked)
    adminSecretInput.addEventListener("keydown", secretKeyPress)

    adminDiscardButton.addEventListener("click", discardButtonClicked)
    adminPublishButton.addEventListener("click", publishButtonClicked)
    adminMakeVisibleButton.addEventListener("click", showEditablesButtonClicked)    
    adminBigpanelVisibilityButton.addEventListener("click", toggleBigPanelVisibility)

    applyUIState()
    return

############################################################
#region internalFunctions
applyUIState = ->
    log "applyUIState"
    uiState.print()

    # applyLoginSectionState()
    # applyControlSectionState()
    # applyBigPanelSectionState()
    # applyVisibleEditablesState()

    if uiState.loginButtonVisible()
        adminLoginButton.setAttribute "class","active"
        adminLogoutButton.setAttribute "class","hidden"
        adminSecretInput.setAttribute "class",""
    else
        adminLogoutButton.setAttribute "class","active"
        adminLoginButton.setAttribute "class","hidden"
        adminSecretInput.setAttribute "class","hidden"

    if spinnerActive then adminLoginPreloader.setAttribute "class",""
    else adminLoginPreloader.setAttribute "class","hidden"


    adminDiscardButton.setAttribute "class",uiState.discardButtonState()
    adminMakeVisibleButton.setAttribute "class",uiState.makeVisibleButtonState()
    adminPublishButton.setAttribute "class",uiState.publishButtonState()
    adminBigpanelVisibilityButton.setAttribute "class",uiState.bigPanelButtonState()

    if uiState.visibleEditables()
        allEditableTexts = document.querySelectorAll("[text-content-key]")
        for editableText in allEditableTexts
            editableText.classList.add("editable-show")
        allEditableImages = document.querySelectorAll("[image-content-key]")
        for editableImage in allEditableImages
            editableImage.classList.add("editable-image")
    else
        allEditableTexts = document.querySelectorAll("[text-content-key]")
        for editableText in allEditableTexts
            editableText.classList.remove("editable-show")

        allEditableImages = document.querySelectorAll("[image-content-key]")
        for editableImage in allEditableImages
            editableImage.classList.remove("editable-image")
    
    return

############################################################
#region adminMessageBox
resetMessageTimeout = ->
    if currentMessageTimeoutId
        clearTimeout(currentMessageTimeoutId)
        currentMessageTimeoutId = 0
    return

setErrorMessage = (message) ->
    resetMessageTimeout()
    adminMessageBox.innerHTML = message
    adminMessageBox.setAttribute("class", "error")
    currentMessageTimeoutId = setTimeout(eraseMessageBox, 3000)
    return

setSuccessMessage = (message) ->
    resetMessageTimeout()
    adminMessageBox.innerHTML = message
    adminMessageBox.setAttribute("class", "success")
    currentMessageTimeoutId = setTimeout(eraseMessageBox, 3000)
    return

setMessage = (message) ->
    resetMessageTimeout()
    adminMessageBox.innerHTML = message
    currentMessageTimeoutId = setTimeout(eraseMessageBox, 3000)
    return

eraseMessageBox = ->
    currentMessageTimeoutId = 0
    adminMessageBox.setAttribute "class",""
    adminMessageBox.innerHTML = ""
    return

#endregion

############################################################
#region eventListeners
loginButtonClicked = ->
    log "loginButtonClicked"
    if adminSecretInput.value then doLogin()
    else adminSecretInput.focus()
    return

logoutButtonClicked = ->
    log "logoutButtonClicked"
    auth.logout()
    return

secretKeyPress = (event) ->
    log "secretKeyPress"
    key = event.keyCode
    if key == 27 then adminSecretInput.value = "" # esc
    if key == 13 then doLogin() # enter
    return


publishButtonClicked = ->
    log "publishButtonClicked"
    if uiState.publishButtonState() == "active" then admin.apply()
    return

showEditablesButtonClicked = ->
    log "showEditablesButtonClicked"

    if uiState.visibleEditables()
        uiState.visibleEditables false
        uiState.makeVisibleButtonState ""
    else 
        uiState.visibleEditables true
        uiState.makeVisibleButtonState "active"
    uiState.save()    
    applyUIState()
    return

discardButtonClicked = ->
    log "discardButtonClicked"
    if uiState.discardButtonState() == "active" then admin.discard()
    return


toggleBigPanelVisibility = ->
    log "toggleBigPanelVisibility"
    
    if(uiState.bigPanelVisible())
        uiState.bigPanelVisible false
        uiState.bigPanelButtonState ""
    else 
        uiState.bigPanelVisible true
        uiState.bigPanelButtonState "active"

    uiState.save()
    bigpanel.applyUIState()
    applyUIState()
    return

#endregion

doLogin = ->
    log "doLogin"
    spinnerActive = true
    applyUIState()
    auth.login(adminSecretInput.value)
    adminSecretInput.value = ""
    return

#endregion

############################################################
bottompanelmodule.authRequestResponded = (state) ->
    log "bottompanelmodule.authRequestResponded"
    spinnerActive = false
    bigpanel.applyUIState()
    applyUIState()
    if state ==  "authorized"
        setSuccessMessage("Erfolgreich authorisiert!")
    if state == "invalidated"
        setErrorMessage("Erfolgreich ausgeloggt!")
    if state == "error"
        setErrorMessage("Login Fehlgeschlagen!")
    return

bottompanelmodule.applyUIState = applyUIState

############################################################
bottompanelmodule.setErrorMessage = setErrorMessage
bottompanelmodule.setSuccessMessage = setSuccessMessage
bottompanelmodule.setMessage = setMessage

module.exports = bottompanelmodule