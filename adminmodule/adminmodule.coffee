adminmodule = {name: "adminmodule"}
############################################################
#region printLogFunctions
log = (arg) ->
    if adminModules.debugmodule.modulesToDebug["adminmodule"]?  then console.log "[adminmodule]: " + arg
    return
ostr = (obj) -> JSON.stringify(obj, null, 4)
olog = (obj) -> log "\n" + ostr(obj)
print = (arg) -> console.log(arg)
#endregion

############################################################
#region modulesFromEnvironment
mustache = require "mustache"

############################################################
mustachekeys = null
templatepreparation = null
network = null
adminpanel = null
appState = null
contentHandler = null
bottomPanel = null
floatingPanel = null
bigPanel = null
imageManagement = null
listManagement = null
linkManagement = null
auth = null
#endregion

############################################################
#region internalProperties
currentContentFallback = ""

############################################################
typingSecret = false
loggingIn = false
token =  ""
panelVisible =  true
showingEditables = false

altIsPressed = 0
#endregion

############################################################
adminmodule.initialize = () ->
    log "adminmodule.initialize"
    mustachekeys = adminModules.mustachekeysmodule
    templatepreparation = adminModules.templatepreparationmodule
    network = adminModules.networkmodule
    adminpanel = adminModules.adminpanelmodule
    appState = adminModules.appstatemodule
    auth = adminModules.authmodule
    contentHandler = adminModules.contenthandlermodule
    bigPanel = adminModules.bigpanelmodule
    floatingPanel = adminModules.floatingpanelmodule
    imageManagement = adminModules.imagemanagementmodule
    listManagement = adminModules.listmanagementmodule
    linkManagement = adminModules.linkmanagementmodule
    bottomPanel = adminModules.bottompanelmodule
    return

############################################################
#region internalFunctions
renderProcess = ->
    log "renderProcess"
    content = contentHandler.content()
    mustachekeys.createMustacheKeys()
    mustacheTemplate = template(pwaMustacheKeymap)
    
    # log mustacheTemplate
    shadowBody = document.createElement("body")
    shadowBody.innerHTML = mustacheTemplate
    templatepreparation.prepareBody(shadowBody)

    preparedTemplate = shadowBody.innerHTML
    # log preparedTemplate

    htmlResult = mustache.render(preparedTemplate, content)
    # log htmlResult

    newBody = document.createElement("body")
    newBody.innerHTML = htmlResult
    adminpanel.attachPanelToBody(newBody)
    document.body = newBody

    ##fire document onload again
    window.dispatchEvent(new Event("load"))

    addAdministrativeEventListeners()
    bigPanel.prepare()
    return

############################################################
addAdministrativeEventListeners = ->
    log "addAdministrativeEventListeners"
    allEditableTexts = document.querySelectorAll("[text-content-key]")
    for editable in allEditableTexts
        editable.addEventListener("keyup", editKeyReleased)
        editable.addEventListener("keydown", editKeyPressed)
        editable.addEventListener("focusin", startedEditing)
        editable.addEventListener("focusout", stoppedEditing)
        editable.addEventListener("click", editableClicked)
        defuseLink(editable)

    allEditableImages = document.querySelectorAll("[image-content-key]")
    for editable in allEditableImages
        editable.addEventListener("click", editableImageClicked)
        defuseLink(editable)

    return

defuseLink = (element) ->
    log "defuseLink"
    # while element?
    #     if element.tagName == "A" then setAttribute("href", "#")        element = element.parentElement
    return

createLink = ->
    log "createLink"
    return

############################################################
#region eventListeners
editableClicked = (event) ->
    log "editableClicked"
    event.preventDefault()
    event.stopPropagation()
    return false

editableImageClicked = (event) ->
    log "editableImageClicked"
    event.preventDefault()
    element = event.target
    imageLabel = element.getAttribute("image-content-key")
    # log imageLabel
    # log element
    # log element.id
    while !imageLabel and element
        element = element.parentElement
        imageLabel = element.getAttribute("image-content-key")
        # log imageLabel
        # log element
        # log element.id

    return unless imageLabel

    bigPanel.activateEdit("images", imageLabel)
    bottomPanel.applyUIState()
    return

editKeyReleased = (event) ->
    log "editKeyReleased"
    key = event.keyCode
    if (key == 18 ) then altIsPressed = false
    return

editKeyPressed = (event) ->
    log "editKeyPressed"
    key = event.keyCode
    if (key == 76 and altIsPressed and event.ctrlKey) then createLink()
    if (key == 18) then altIsPressed = true
    if (key == 27) #escape
        this.innerHTML = currentContentFallback
        document.activeElement.blur()
    return

startedEditing = (event) ->
    log "startedEditing"
    element = event.target
    element.classList.add("editing")
    activateFloatingPanelFor(element)
    currentContentFallback = cleanContentHTML(element.innerHTML)
    return

stoppedEditing = (event) ->
    log "stoppedEditing"
    floatingPanel.disappear()
    element = event.target
    element.classList.remove("editing")
    content = cleanContentHTML(element.innerHTML)
    element.innerHTML = content
    # log "new Content: " + content
    return if content == currentContentFallback
    contentKeyString = element.getAttribute("text-content-key")
    newContentText(contentKeyString, content)
    return

#endregion

############################################################
#region contentCleaning
getCleanBold = (el) ->
    log "getCleanBold"
    log el.innerHTML
    el.innerHTML = cleanContentHTML(el.innerHTML)
    return el

getCleanAnchor = (el) ->
    log "getCleanAnchor"
    log el.innerHTML
    el.innerHTML = cleanContentHTML(el.innerHTML)
    # href = el.getAttribute("href")
    # if href then el.setAttribute("href", href)
    return el

cleanContentHTML = (innerHTML) ->
    log "cleanContentHTML"
    log innerHTML
    el = document.createElement("div")
    el.innerHTML = innerHTML
    children = [el.children...]
    for child in children
        if child.tagName == "B" then newNode = getCleanBold(child)
        else if child.tagName == "A" then newNode = getCleanAnchor(child)
        else if child.tagName == "BR" then newNode = document.createElement("br")
        else newNode = cleanContentHTML(child.innerHTML)
        log child.innerHTML
        log child.tagName
        if typeof newNode == "string"
            if newNode != "<br>" then newNode = "<br>"+newNode
            child.insertAdjacentHTML("beforebegin", newNode)
            el.removeChild(child)
        else
            el.replaceChild(newNode, child)
    return el.innerHTML

#endregion

############################################################
#region contentEditing
newContentText = (contentKeyString, content) ->
    log "newContentText"
    log contentKeyString
    log content
    token = appState.token()
    langTag = pwaContent.languageTag
    path = window.location.pathname
    documentName = path.split("/").pop()
    updateObject = {langTag, documentName, contentKeyString, content, token}
    oldContent = currentContentFallback
    try
        response = await network.scicall("update", updateObject)
        edits = {}
        edits[contentKeyString] = content
        contentHandler.reflectEdits(edits)
        updateSuccess(response)
    catch err then revertEdit(contentKeyString, oldContent)
    return

############################################################
revertEdit = (contentKeyString, oldText) ->
    log "revertEdit"
    bottomPanel.setErrorMessage("Veränderung konnte nicht angenommen werden!")
    selector = "[text-content-key='"+contentKeyString+"']"
    element = document.querySelector(selector)
    element.innerHTML = oldText
    return

setCleanState = ->
    log "setCleanState"
    appState.setClean()
    bottomPanel.applyUIState()
    return

setDirtyState = ->
    log "setDirtyState"
    appState.setDirty()
    bottomPanel.applyUIState()
    return

############################################################
activateFloatingPanelFor = (element) ->
    log "activateFloatingPanelFor"
    floatingPanel.initializeForElement(element)
    left = element.getBoundingClientRect().x
    bottom = window.innerHeight - element.getBoundingClientRect().y
    floatingPanel.appear(left, bottom)
    return

#endregion

############################################################
#region networkEvents
updateSuccess = (response) ->
    log "updateSuccess"
    setDirtyState()
    bottomPanel.setSuccessMessage("Veränderung angenommen")
    return

prepareImages = ->
    log "prepareImages"
    content = contentHandler.content()
    imageManagement.setImages(content.images)
    return

handleDataState = (response) ->
    log "handleDataState"
    olog response
    await contentHandler.prepareOriginal(response.contentHash)
    prepareImages()
    contentHandler.reflectEdits(response.edits)
    if Object.keys(response.edits).length > 0 then setDirtyState()
    else setCleanState()
    renderProcess()
    return

dataStateRequestError = ->
    log "dataStateRequestError"
    auth.logout()
    return

#endregion

#endregion

############################################################
#region exposedFunctions
adminmodule.noticeContentChange = -> setDirtyState()

adminmodule.noticeAuthorizationSuccess = ->
    log "adminmodule.noticeAuthorization"
    token = appState.token()
    langTag = pwaContent.languageTag
    path = window.location.pathname
    documentName = path.split("/").pop();
    communicationObject = {langTag, documentName, token}
    try
        response = await network.scicall("getDataState", communicationObject)
        await handleDataState(response)
    catch err then dataStateRequestError()
    return

adminmodule.noticeAuthorizationFail = ->
    log "adminmodule.noticeAuthorizationFail"
    return

adminmodule.discard = ->
    log "adminmodule.discard"
    try
        langTag = pwaContent.languageTag
        await network.scicall("discard", {langTag, token})
        contentHandler.reflectEdits({})
        setCleanState()
        bottomPanel.setSuccessMessage("Alle Änderungen wurden verworfen")
        renderProcess()
    catch err
        bottomPanel.setErrorMessage("Keine Änderungen wurden verworfen!")
    return

adminmodule.apply = ->
    log "adminmodule.apply"
    try
        token = appState.token()
        langTag = pwaContent.languageTag
        path = window.location.pathname
        documentName = path.split("/").pop();
        communicationObject = {langTag, documentName, token}        
        await network.scicall("apply", {langTag, token})
        response = await network.scicall("getDataState", communicationObject)
        await handleDataState(response)
        bottomPanel.setSuccessMessage("Alle Änderungen wurden übernommen")
    catch err
        bottomPanel.setErrorMessage("Keine Änderungen wurden übernommen!")
    return

adminmodule.start = ->
    log "adminmodule.start"
    prepareImages()
    renderProcess()
    return

#endregion

module.exports = adminmodule