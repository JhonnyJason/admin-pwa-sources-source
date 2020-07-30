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
uiState = null
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
    uiState = adminModules.uistatemodule
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

    bigPanel.prepare()
    addAdministrativeEventListeners()
    applyEditableVisibility()
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
    selection = window.getSelection()
    rangeCount = selection.rangeCount
    if rangeCount > 1 or rangeCount < 1 then return
    link = document.createElement("a")
    link.setAttribute("href", "#")
    range = selection.getRangeAt(0)
    range.surroundContents(link)
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
    currentContentFallback = cleanContentHTML(element.innerHTML)
    activateFloatingPanelFor(element)
    return

stoppedEditing = (event) ->
    log "stoppedEditing"
    floatingPanel.disappear()
    element = event.target
    isLink = element.getAttribute("is-link")
    element.classList.remove("editing")
    content = cleanContentHTML(element.innerHTML, isLink)
    log "new content: " + content
    element.innerHTML = content
    # log "new Content: " + content
    return if content == currentContentFallback
    contentKeyString = element.getAttribute("text-content-key")
    newContentText(contentKeyString, content, currentContentFallback)
    return

#endregion

############################################################
#region contentCleaning
getCleanBold = (el) ->
    # log "getCleanBold"
    # log el.innerHTML
    el.innerHTML = cleanContentHTML(el.innerHTML)
    return el

getCleanAnchor = (el) ->
    # log "getCleanAnchor"
    # log el.innerHTML
    el.innerHTML = cleanContentHTML(el.innerHTML)
    # href = el.getAttribute("href")
    # if href then el.setAttribute("href", href)
    return el

cleanContentHTML = (innerHTML, isLink) ->
    # log "cleanContentHTML"
    # log innerHTML
    el = document.createElement("div")
    el.innerHTML = innerHTML
    children = [el.children...]
    for child in children
        if child.tagName == "B" then newNode = getCleanBold(child)
        else if child.tagName == "A" && !isLink then newNode = getCleanAnchor(child)
        else if child.tagName == "BR" then newNode = document.createElement("br")
        else newNode = cleanContentHTML(child.innerHTML)
        # log child.innerHTML
        # log child.tagName
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
applyEditableVisibility = ->
    log "applyEditableVisibility"
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
newContentText = (contentKeyString, content, fallback) ->
    log "newContentText"
    log contentKeyString
    log content
    token = appState.token()
    langTag = pwaContent.languageTag
    path = window.location.pathname
    documentName = path.split("/").pop()
    updateObject = {langTag, documentName, contentKeyString, content, token}
    try
        response = await network.scicall("update", updateObject)
        applyEdit(contentKeyString, content)
        contentHandler.reflectEdit(contentKeyString, content)
        updateSuccess(response)
    catch err then revertEdit(contentKeyString, fallback)
    return

newContentList = (contentKeyString, content, fallback) ->
    log "newContentList"
    log contentKeyString
    log content
    token = appState.token()
    langTag = pwaContent.languageTag
    path = window.location.pathname
    documentName = path.split("/").pop()
    updateObject = {langTag, documentName, contentKeyString, content, token}
    try
        response = await network.scicall("update", updateObject)
        listManagement.setNewList(content, contentKeyString)
        contentHandler.reflectEdit(contentKeyString, content)
        updateSuccess(response)
    catch err then revertListEdit(contentKeyString, fallback)
    adminmodule.start()
    return

newImages = (fallback) ->
    log "newImages"
    token = appState.token()
    langTag = pwaContent.languageTag
    path = window.location.pathname
    documentName = path.split("/").pop()
    content = contentHandler.content().images
    contentKeyString = "images"
    updateObject = {langTag, documentName, contentKeyString, content, token}
    try
        response = await network.scicall("update", updateObject)
        updateSuccess(response)
    catch err then revertImagesEdit(fallback)
    return

############################################################
revertImagesEdit = (oldImages) ->
    log "revertImagesEdit"
    contentHandler.content().images = oldImages
    bottomPanel.setErrorMessage("Veränderung konnte nicht angenommen werden!")    
    return

revertListEdit = (contentKeyString, oldList) ->
    log "revertListEdit"
    log "actually nothing to do here^^..."
    bottomPanel.setErrorMessage("Veränderung konnte nicht angenommen werden!")
    return

applyEdit = (contentKeyString, newContent) ->
    log "applyEdit"
    selector = "[text-content-key='"+contentKeyString+"']"
    elements = document.querySelectorAll(selector)
    for element in elements
        element.innerHTML = newContent
    return

revertEdit = (contentKeyString, oldContent) ->
    log "revertEdit"
    bottomPanel.setErrorMessage("Veränderung konnte nicht angenommen werden!")
    selector = "[text-content-key='"+contentKeyString+"']"
    elements = document.querySelectorAll(selector)
    for element in elements
        element.innerHTML = oldContent
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
    floatingPanel.initializeForElement(element, currentContentFallback)
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
adminmodule.start = ->
    log "adminmodule.start"
    prepareImages()
    renderProcess()
    return

############################################################
#region noticeStuff
adminmodule.noticeVisibilityChanged = ->
    log "adminmodule.noticeVisibilityChanged"
    applyEditableVisibility()
    return

adminmodule.noticeImageSwaps = (moves) ->
    log "adminmodule.noticeImageSwaps"
    token = appState.token()
    assetType = "images"
    dataObject = {assetType, moves, token}
    try
        await network.scicall("moveAssets", dataObject)
        console.log("/moveAssets success!")
    catch err 
        log err
        console.log("/moveAssets failure!")
    return

    return

adminmodule.noticeImagesEdits = (fallback) ->
    log "adminmodule.noticeImagesEdits"
    newImages(fallback)
    return

adminmodule.noticeImagesEdits = (fallback) ->
    log "adminmodule.noticeImagesEdits"
    newImages(fallback)
    return

adminmodule.noticeListEdit = (contentKeyString, newContent, fallback) ->
    log "adminmodule.noticeListEdit"
    console.log ostr newContent
    newContentList(contentKeyString, newContent, fallback)
    return

adminmodule.noticeElementEdit = (element, fallback) ->
    log "adminmodule.noticeElementEdit"
    content = cleanContentHTML(element.innerHTML)
    # log ""+element
    element.innerHTML = content
    contentKeyString = element.getAttribute("text-content-key")
    newContentText(contentKeyString, content, fallback)
    return

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

#endregion

############################################################
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

#endregion

module.exports = adminmodule