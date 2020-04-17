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

    imagesListElementContainer = adminImagesTabcontent.querySelector(".list-element-container")
    imagesEditElementContainer = adminImagesTabcontent.querySelector(".edit-element-container")
    listsListElementContainer = adminListsTabcontent.querySelector(".list-element-container")
    listsEditElementContainer = adminListsTabcontent.querySelector(".edit-element-container")
    linksListElementContainer = adminLinksTabcontent.querySelector(".list-element-container")
    linksEditElementContainer = adminLinksTabcontent.querySelector(".edit-element-container")

    adminImagesTabhead.addEventListener("click", adminImagesTabheadClicked)
    adminListsTabhead.addEventListener("click", adminListsTabheadClicked)
    adminLinksTabhead.addEventListener("click", adminLinksTabheadClicked)

    imageManagement.setImages(pwaContent.images)
    bigpanelmodule.applyUIState()
    return

#############################################################
#region internalFunctions
############################################################
#region eventListeners
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
    setImagesTabcontent()
    setListsTabcontent()
    setLinksTabcontent()
    bigpanelmodule.applyUIState()
    return

############################################################
setImagesTabcontent = ->
    log "setImagesTabcon
    tent"

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

    # linksListElementContainer.innerHTML = ""
    # linksEditElementContainer.innerHTML = ""

    # for label in availableLists
    #     listElement = linkManagement.getListElement label
    #     linksListElementContainer.appendChild listElement
    #     editElement = linkManagement.getEditElement label
    #     linksEditElementContainer.appendChild editElement

    return

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
    if activeTab == "images"
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
        adminImagesTabcontent.classList.remove("active")
        adminImagesTabhead.classList.remove("active")
        adminListsTabcontent.classList.add("active")
        adminListsTabhead.classList.add("active")
        adminLinksTabcontent.classList.remove("active")
        adminLinksTabhead.classList.remove("active")
    if activeTab == "links"
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
    if type  == "links"
        uiState.activeTab "links"
        uiState.activeLinkEdit label
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