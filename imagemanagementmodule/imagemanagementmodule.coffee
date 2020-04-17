imagemanagementmodule = {name: "imagemanagementmodule"}
############################################################
#region printLogFunctions
log = (arg) ->
    if adminModules.debugmodule.modulesToDebug["imagemanagementmodule"]?  then console.log "[imagemanagementmodule]: " + arg
    return
ostr = (obj) -> JSON.stringify(obj, null, 4)
olog = (obj) -> log "\n" + ostr(obj)
print = (arg) -> console.log(arg)
#endregion

############################################################
decamelize = require "decamelize"
network = null
appState = null
bottomPanel = null
admin = null

############################################################
images = null
imageInformationMap = {}

############################################################
imagemanagementmodule.initialize = () ->
    log "imagemanagementmodule.initialize"
    appState = adminModules.appstatemodule
    network = adminModules.networkmodule
    bottomPanel = adminModules.bottompanelmodule
    admin = adminModules.adminmodule
    return

############################################################
#region internalFunctions
fileInputChanged = (event) ->
    log "fileInputChanged"
    input = event.target 
    imageLabel = input.getAttribute("name")
    file = input.files[0]
    return unless file
    editElement = input.parentElement.parentElement
    imagePreview = editElement.querySelector(".admin-bigpanel-image-preview")
    imagePreview.src = URL.createObjectURL(file)
    thumbnailPreview = editElement.querySelector(".admin-bigpanel-thumbnail-preview")
    if thumbnailPreview then thumbnailPreview.src = URL.createObjectURL(file)
    return

uploadButtonClicked = (event) ->
    log "uploadButtonClicked"
    imageLabel = event.target.getAttribute("image-label")
    fileInput = event.target.parentElement.querySelector("input")
    file = fileInput.files[0]
    return unless file
    uploadFile(imageLabel, file)
    return

uploadFile = (label, file) ->
    log "uploadFile"
    formData = new FormData()
    formData.append(label, file)

    token = appState.token()
    formData.append("token", token)
    
    langTag = pwaContent.languageTag
    formData.append("langTag", langTag)
    
    path = window.location.pathname
    documentName = path.split("/").pop() 
    formData.append("documentName", documentName)

    for pair in formData.entries()
        log(pair[0]+ ', ' + pair[1])

    try
        response = await network.uploadImage(formData)
        bottomPanel.setSuccessMessage("Erfolgreich hochgeladen")
        admin.noticeContentChange()
        log response
    catch err 
        log err
        bottomPanel.setErrorMessage("Upload Failed!")
    return

############################################################
digestImages = ->
    log "digestImages"
    imageInformationMap = {}
    for label,image of images
        imageInformationMap[label] = {}
        imageInfo = imageInformationMap[label]
        imageInfo.editElement = createImageEditElement(label, image)
        imageInfo.listElement = createImageListElement(label, image)
        imageInfo.id = decamelize(label, "-")
        imageInfo.label = label
        imageInfo.info = image
    olog imageInformationMap
    return

############################################################
createImageEditElement = (label, image) ->
    log "createImageEditElement"
    div = document.createElement("div")
    innerHTML = getEditHeadHTML(image.name, label)
    innerHTML += getFileUploadSectionHTML()
    innerHTML += getImagePreviewSectionHTML(image)

    div.innerHTML = innerHTML
    leftArrow = div.querySelector(".admin-bigpanel-arrow-left")
    fileInput = div.querySelector("input")
    uploadButton = div.querySelector(".admin-bigpanel-upload-button")

    div.classList.add("admin-bigpanel-edit-element")
    div.setAttribute "image-label",label
    leftArrow.setAttribute "image-label",label
    fileInput.setAttribute "name",label
    uploadButton.setAttribute "image-label",label

    fileInput.addEventListener("change", fileInputChanged)
    uploadButton.addEventListener("click", uploadButtonClicked)
    return div

createImageListElement = (label, image) ->
    log "createImageListElement"
    div = document.createElement("div")
    innerHTML = "<div>"+image.name+"</div>"
    innerHTML += getArrowRightHTML()
    div.innerHTML = innerHTML
    div.classList.add("admin-bigpanel-list-element")
    div.setAttribute "image-label",label
    return div

############################################################
#region createElementHelpers
getEditHeadHTML = (name) ->
    html = "<div class='admin-bigpanel-edit-head'>"
    html += getArrowLeftHTML()
    html += "<div>"+name+"</div>"
    html += "</div>"
    return html

getFileUploadSectionHTML = ->
    html = "<div class='admin-bigpanel-file-upload-section'>"
    html += "<input type='file' "
    html += "class='admin-bigpanel-file-upload-input'>"
    html += getUploadButtonHTML()
    html += "</div>"
    return html

getImagePreviewSectionHTML = (image) ->
    html = "<div class='admin-bigpanel-image-preview-section'>"
    html += "<img class='admin-bigpanel-image-preview' "
    html += "src='/img/"+image.name+"' "
    html += "height='"+image.height
    html += "' width='"+image.width+"'>"
    if image.thumbnail
        html += "<img class='admin-bigpanel-thumbnail-preview' "
        html += "src='/img/"+image.thumbnail.name+"' " 
        html += "height='"+image.thumbnail.height+"' "
        html += "width='"+image.thumbnail.width"'>"
    html += "</div>"
    return html

############################################################
getArrowLeftHTML = ->
    html = "<div class='admin-bigpanel-arrow-left'>"
    html += "<svg><use href='#admin-svg-arrow-left-icon'></svg>"
    html += "</div>"
    return html

getUploadButtonHTML = ->
    html = "<div class='admin-bigpanel-upload-button'>" 
    html += "<svg><use href='#admin-svg-upload-icon'></svg>"
    html += "</div>"
    return html

############################################################
getArrowRightHTML = ->
    html = "<div class='admin-bigpanel-arrow-right'>"
    html += "<svg><use href='#admin-svg-arrow-right-icon'></svg>"
    html += "</div>"
    return html

#endregion

############################################################
#region exposedFunctions
imagemanagementmodule.setImages = (newImages) ->
    log "imagemanagementmodule.setImageElements"
    olog newImages
    images = newImages
    digestImages()
    return

imagemanagementmodule.getListElement = (imageLabel) ->
    log "imagemanagementmodule.getListElement"
    return unless imageInformationMap[imageLabel]
    return imageInformationMap[imageLabel].listElement

imagemanagementmodule.getEditElement = (imageLabel) ->
    log "imagemanagementmodule.getEditElement"
    return unless imageInformationMap[imageLabel] 
    return imageInformationMap[imageLabel].editElement

imagemanagementmodule.elementExists = (imageLabel) ->
    log "imagemanagementmodule.elementExists"
    if !imageInformationMap[imageLabel] then return false
    id = imageInformationMap[imageLabel].id
    if !document.getElementById(id) then return false
    return true

imagemanagementmodule.getImages = -> images

#endregion

module.exports = imagemanagementmodule