authmodule = {name: "authmodule"}
############################################################
#region printLogFunctions
log = (arg) ->
    if adminModules.debugmodule.modulesToDebug["authmodule"]?  then console.log "[authmodule]: " + arg
    return
ostr = (obj) -> JSON.stringify(obj, null, 4)
olog = (obj) -> log "\n" + ostr(obj)
print = (arg) -> console.log(arg)
#endregion

############################################################
network = null
appState = null
bottomPanel = null
adminModule = null

############################################################
authRequestPending = false
tokenToCheck = ""

############################################################
authmodule.initialize = () ->
    log "authmodule.initialize"
    network = adminModules.networkmodule
    appState = adminModules.appstatemodule
    bottomPanel = adminModules.bottompanelmodule
    adminModule = adminModules.adminmodule
    return

############################################################
#region requestFunctions
sendInvalidateRequest = (token) ->
    log "sendInvalidateRequest"
    return if authRequestPending
    data = { token }
    authRequestPending = true
    network.requestBackendService('invalidate', data, invalidateSuccess, invalidateFail)
    return

sendLoginRequest = (secret) ->
    log "sendLoginRequest"
    return if authRequestPending
    data = { secret }
    authRequestPending = true
    network.requestBackendService('login', data, authSuccess, authFail);
    return

sendTokenCheckRequest = (token) ->
    log "sendLoginRequest"
    return if authRequestPending
    tokenToCheck = token
    authRequestPending = true
    data = { token }
    network.requestBackendService('tokenCheck', data, authSuccess, authFail);
    return

#endregion

############################################################
#region networkCallbacks
authSuccess = (response) ->
    log "authSuccess"
    authRequestPending = false
    if !tokenToCheck then appState.setAuthenticated(response.token)
    else
        appState.setAuthenticated(tokenToCheck)
        tokenToCheck = ""
    bottomPanel.authRequestResponded("authorized")
    adminModule.noticeAuthorizationSuccess()
    return

authFail = (response) ->
    log "authFail"
    authRequestPending = false
    tokenToCheck = ""
    appState.setUnauthenticated()
    bottomPanel.authRequestResponded("error")
    adminModule.noticeAuthorizationFail()
    return

invalidateSuccess = (response) ->
    log "invalidateSuccess"
    authRequestPending = false
    tokenToCheck = ""
    appState.setUnauthenticated()
    bottomPanel.authRequestResponded("invalidated")
    return

invalidateFail = (response) ->
    log "invalidateFail"
    authRequestPending = false
    tokenToCheck = ""
    appState.setUnauthenticated()
    bottomPanel.authRequestResponded("error")
    return

#endregion

############################################################
authmodule.login = (password) ->
    log "authmodule.login"
    sendLoginRequest(password)
    return

authmodule.logout = () ->
    log "authmodule.logout"
    token = appState.token()
    if token then sendInvalidateRequest(token)
    return 

authmodule.tokenCheck = () ->
    log "authmodule.tokenCheck"
    token = appState.token()
    log "currentToken: " + token
    if token then sendTokenCheckRequest(token)
    return

module.exports = authmodule