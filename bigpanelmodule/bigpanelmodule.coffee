bigpanelmodule = {name: "bigpanelmodule"}
############################################################
#region printLogFunctions
log = (arg) ->
    if adminModules.debugmodule.modulesToDebug["bigpanelmodule"]?  then console.log "[bigpanelmodule]: " + arg
    return
ostr = (obj) -> JSON.stringify(obj, null, 4)
olog = (obj) -> log "\n" + ostr(obj)
print = (arg) -> console.log(arg)
#endregion

############################################################
uiState = null
imageManagement = null
linkManagement = null
listManagement = null
contentHandler = null

############################################################
#region internalProperties
availableImages = []
availableLists = []
availableLinks = []

############################################################
imagesListElementContainer = null
imagesEditElementContainer = null
listsListElementContainer = null
listsEditElementContainer = null
linksListElementContainer = null
linksEditElementContainer = null

#endregion

############################################################
bigpanelmodule.initialize = () ->
    log "bigpanelmodule.initialize"
    uiState = adminModules.uistatemodule
    imageManagement = adminModules.imagemanagementmodule
    linkManagement = adminModules.linkmanagementmodule
    listManagement = adminModules.listmanagementmodule
    contentHandler = adminModules.contenthandlermodule

    imagesListElementContainer = adminImagesTabcontent.querySelector(".list-element-container")
    imagesEditElementContainer = adminImagesTabcontent.querySelector(".edit-element-container")
    listsListElementContainer = adminListsTabcontent.querySelector(".list-element-container")
    listsEditElementContainer = adminListsTabcontent.querySelector(".edit-element-container")
    linksListElementContainer = adminLinksTabcontent.querySelector(".list-element-container")
    linksEditElementContainer = adminLinksTabcontent.querySelector(".edit-element-container")

    adminMetaTabhead.addEventListener("click", adminMetaTabheadClicked)
    adminImagesTabhead.addEventListener("click", adminImagesTabheadClicked)
    adminListsTabhead.addEventListener("click", adminListsTabheadClicked)
    adminLinksTabhead.addEventListener("click", adminLinksTabheadClicked)

    setMetaTabcontent()
    imageManagement.setImages(pwaContent.images)
    bigpanelmodule.applyUIState()
    return

#############################################################
#region internalFunctions
############################################################
#region eventListeners
adminMetaTabheadClicked = ->
    log "adminMetaTabheadClicked"
    uiState.activeTab("meta")
    uiState.save()
    bigpanelmodule.applyUIState()
    return

adminImagesTabheadClicked = ->
    log "adminImagesTabheadClicked"
    uiState.activeTab("images")
    uiState.save()
    bigpanelmodule.applyUIState()
    return

adminListsTabheadClicked = ->
    log "adminListsTabheadClicked"
    uiState.activeTab("lists")
    uiState.save()
    bigpanelmodule.applyUIState()
    return

adminLinksTabheadClicked = ->
    log "adminLinksTabheadClicked"
    uiState.activeTab("links")
    uiState.save()
    bigpanelmodule.applyUIState()
    return

imageElementClicked = (event) ->
    log "imageElementClicked"
    imageLabel = event.target.getAttribute("image-label")
    bigpanelmodule.activateEdit("images", imageLabel)
    return

imageElementBackClicked = (event) ->
    log "imageElementBackClicked"
    uiState.activeImageEdit ""
    uiState.save()
    bigpanelmodule.applyUIState()
    return

#endregion

############################################################
#region injectElementsToDOM
setAllElementsToDOM = ->
    log "setAllElementsToDOM"
    setMetaTabcontent()
    setImagesTabcontent()
    setListsTabcontent()
    setLinksTabcontent()
    bigpanelmodule.applyUIState()
    return

############################################################
setMetaTabcontent = ->
    log "setMetaTabcontent"
    adminMetaTabcontent.innerHTML = ""
    
    contents = contentHandler.content()

    html = ""
    for label,content of contents
        html += createMetaEditHTML(label,content)

    adminMetaTabcontent.innerHTML = html    
    return

setImagesTabcontent = ->
    log "setImagesTabcontent"

    imagesListElementContainer.innerHTML = ""
    imagesEditElementContainer.innerHTML = ""

    for label in availableImages
        listElement = imageManagement.getListElement label
        imagesListElementContainer.appendChild listElement
        editElement = imageManagement.getEditElement label
        imagesEditElementContainer.appendChild editElement

    return

setListsTabcontent = ->
    log "setListsTabcontent"

    # listsListElementContainer.innerHTML = ""
    # listsEditElementContainer.innerHTML = ""

    # for label in availableLists
    #     listElement = listManagement.getListElement label
    #     listsListElementContainer.appendChild listElement
    #     editElement = listManagement.getEditElement label
    #     listsEditElementContainer.appendChild editElement

    return

setLinksTabcontent = ->
    log "setLinksTabcontent"

    adminLinksTabcontent.innerHTML = ""
    contentElement = linkManagement.getContentElement()
    adminLinksTabcontent.appendChild(contentElement)

    return

############################################################
createMetaEditHTML = (label, content) ->
    log "createMetaEditHTML"
    return "" unless typeof content == "string"
    html = "<div class='meta-edit-element'>"
    html += "<div class='meta-edit-label'>"
    html += label
    html += ":</div>"
    html += "<div text-content-key='"+label+"' contentEditable>"
    html += content
    html += "</div>"
    html += "</div>"
    return html

#endregion

############################################################
connectImageElements = (label, listElement, editElement) ->
    log "connectImageElements"
    availableImages.push label
    listElement.addEventListener("click", imageElementClicked)
    backButton = editElement.querySelector(".admin-bigpanel-arrow-left")
    backButton.addEventListener("click", imageElementBackClicked)
    return

#endregion

############################################################
#region exposedFunctions
bigpanelmodule.applyUIState = ->
    log "bigpanelmodule.applyUIState"

    if uiState.bigPanelVisible()
        adminBigpanel.classList.remove("hidden")
    else
        adminBigpanel.classList.add("hidden")

    activeTab = uiState.activeTab()

    if activeTab == "meta"
        adminMetaTabcontent.classList.add("active")
        adminMetaTabhead.classList.add("active")
        adminImagesTabcontent.classList.remove("active")
        adminImagesTabhead.classList.remove("active")
        adminListsTabcontent.classList.remove("active")
        adminListsTabhead.classList.remove("active")
        adminLinksTabcontent.classList.remove("active")
        adminLinksTabhead.classList.remove("active")

    if activeTab == "images"
        adminMetaTabhead.classList.remove("active")
        adminMetaTabcontent.classList.remove("active")
        adminImagesTabcontent.classList.add("active")
        adminImagesTabhead.classList.add("active")
        adminListsTabcontent.classList.remove("active")
        adminListsTabhead.classList.remove("active")
        adminLinksTabcontent.classList.remove("active")
        adminLinksTabhead.classList.remove("active")
 
        activeEdit = uiState.activeImageEdit()
 
        if activeEdit then editElement = imageManagement.getEditElement(activeEdit)
        else editElement = null
 
        listContainer = adminImagesTabcontent.querySelector(".list-element-container")
        editContainer = adminImagesTabcontent.querySelector(".edit-element-container")
 
        for element in editContainer.children
            element.classList.remove("active")
        listContainer.classList.remove("hidden")
 
        if  editElement
            listContainer.classList.add("hidden")
            editElement.classList.add("active")
 
    if activeTab == "lists"
        adminMetaTabhead.classList.remove("active")
        adminMetaTabcontent.classList.remove("active")
        adminImagesTabcontent.classList.remove("active")
        adminImagesTabhead.classList.remove("active")
        adminListsTabcontent.classList.add("active")
        adminListsTabhead.classList.add("active")
        adminLinksTabcontent.classList.remove("active")
        adminLinksTabhead.classList.remove("active")

    if activeTab == "links"
        adminMetaTabhead.classList.remove("active")
        adminMetaTabcontent.classList.remove("active")
        adminImagesTabcontent.classList.remove("active")
        adminImagesTabhead.classList.remove("active")
        adminListsTabcontent.classList.remove("active")
        adminListsTabhead.classList.remove("active")
        adminLinksTabcontent.classList.add("active")
        adminLinksTabhead.classList.add("active")

    ## TODO display the correct tab or the specific managementpanel
    return

bigpanelmodule.setImageElements = (newImages) ->
    log "bigpanelmodule.setImageElements"
    olog newImages
    imageManagement.setImages(newImages)
    bigpanelmodule.applyUIState()
    return

bigpanelmodule.prepare = ->
    log "bigpanelmodule.prepare"
    images = imageManagement.getImages()
    availableImages = []
    for label,image of images
        if imageManagement.elementExists(label)
            listElement = imageManagement.getListElement(label)
            editElement = imageManagement.getEditElement(label)
            connectImageElements(label, listElement, editElement)
    setAllElementsToDOM()
    return

bigpanelmodule.activateEdit = (type, label) ->
    log "bigpanelmodule.activateEdit"

    if type ==  "images"
        uiState.activeTab "images"
        uiState.activeImageEdit label
    if type == "lists"
        uiState.activeTab "lists"
        uiState.activeListEdit label

    uiState.bigPanelVisible true
    uiState.bigPanelButtonState "active"
    uiState.save()
    bigpanelmodule.applyUIState()
    return

#endregion

module.exports = bigpanelmodule