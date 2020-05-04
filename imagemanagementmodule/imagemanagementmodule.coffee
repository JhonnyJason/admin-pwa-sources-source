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
#region modulesFromEnvironment
decamelize = require "decamelize"
Croppie = require 'croppie'

############################################################
network = null
appState = null
bottomPanel = null
admin = null

#endregion

############################################################
images = null
imageInformationMap = {}
currentCroppie = null
croppingEditElement = null

############################################################
imagemanagementmodule.initialize = ->
    log "imagemanagementmodule.initialize"
    appState = adminModules.appstatemodule
    network = adminModules.networkmodule
    bottomPanel = adminModules.bottompanelmodule
    admin = adminModules.adminmodule
    return

############################################################
#region internalFunctions
killCroppie = ->
    log "killCroppie"
    return unless currentCroppie
    if croppingEditElement then croppingEditElement.classList.remove("cropping")

    currentCroppie.destroy()

    currentCroppie = null
    croppingEditElement = null
    return

############################################################
#region eventListeners
mainScaledCheckboxChanged = (event) ->
    log "mainScaledCheckboxChanged"
    log event.target.checked
    label = event.target.getAttribute("image-label")
    imageInfo = imageInformationMap[label]
    if !imageInfo? then throw new Error("ERROR!! We did not have an Image Information Object here!" )
    if !imageInfo.editElement? then throw new Error("ERROR!! We did not have an editElement on the imageInfoObject!" )
    
    if event.target.checked
        newWidth = parseFloat(event.target.getAttribute("scale-to-width"))
        newHeight = parseFloat(event.target.getAttribute("scale-to-height"))
    else
        newWidth = imageInfo.info.width
        newHeight = imageInfo.info.height

    imagePreview = imageInfo.editElement.querySelector(".admin-bigpanel-image-preview")
    imagePreview.setAttribute("width", newWidth)
    imagePreview.setAttribute("height", newHeight)
    return

thumbnailScaledCheckboxChanged = (event) ->
    log "thumbnailScaledCheckboxChanged"
    log event.target.checked
    label = event.target.getAttribute("image-label")
    imageInfo = imageInformationMap[label]
    if !imageInfo? then throw new Error("ERROR!! We did not have an Image Information Object here!" )
    if !imageInfo.editElement? then throw new Error("ERROR!! We did not have an editElement on the imageInfoObject!" )
    if !imageInfo.info.thumbnail? then throw new Error("ERROR!! We did not have an thumbnail info on the imageInfoObject!" )
    
    if event.target.checked
        newWidth = parseFloat(event.target.getAttribute("scale-to-width"))
        newHeight = parseFloat(event.target.getAttribute("scale-to-height"))
    else
        newWidth = imageInfo.info.thumbnail.width
        newHeight = imageInfo.info.thumbnail.height

    thumbnailPreview = imageInfo.editElement.querySelector(".admin-bigpanel-thumbnail-preview")
    thumbnailPreview.setAttribute("width", newWidth)
    thumbnailPreview.setAttribute("height", newHeight)
    return

fileInputChanged = (event) ->
    log "fileInputChanged"
    input = event.target 
    imageLabel = input.getAttribute("name")
    file = input.files[0]
    return unless file
    editElement = input.parentElement.parentElement
    imagePreviewSection = editElement.querySelector(".admin-bigpanel-image-preview-section")
    imagePreview = imagePreviewSection.querySelector(".admin-bigpanel-image-preview")
    sizeIndicator = imagePreviewSection.querySelector(".admin-bigpanel-image-size-indicator")
    imagePreview.src = URL.createObjectURL(file)
    imageInformationMap[imageLabel].mainUploadCandidate = file
    initializeSizeIndicator(sizeIndicator, file.size)   
    
    thumbnailPreviewSection = editElement.querySelector(".admin-bigpanel-thumbnail-preview-section")
    if thumbnailPreviewSection?
        thumbnailPreview = thumbnailPreviewSection.querySelector(".admin-bigpanel-thumbnail-preview")
        thumbnailPreview.src = URL.createObjectURL(file)
        imageInformationMap[imageLabel].thumbnailUploadCandidate = file
        sizeIndicator = thumbnailPreviewSection.querySelector(".admin-bigpanel-image-size-indicator")
        initializeSizeIndicator(sizeIndicator, file.size)

    return

quitButtonClicked = (event) ->
    log "quitButtonClicked"
    killCroppie()
    return

doCropButtonClicked = (event) ->
    log "doCropButtonClicked"
    return unless croppingEditElement
    imageLabel = event.target.getAttribute("image-label")
    thumbnail = (event.target.getAttribute("thumbnail") == "true")
    log imageLabel
    log thumbnail
    quality = event.target.parentElement.querySelector("input").value
    quality = parseFloat(quality)

    cropOptions = 
        type: "blob"
        size: "viewport"
        format: "jpeg"
        quality: quality

    imageBlob = await currentCroppie.result(cropOptions)

    if thumbnail
        thumbnailPreviewSection = croppingEditElement.querySelector(".admin-bigpanel-thumbnail-preview-section")
        thumbnailPreview = thumbnailPreviewSection.querySelector(".admin-bigpanel-thumbnail-preview")
        thumbnailPreview.src = URL.createObjectURL(imageBlob)
        imageInformationMap[imageLabel].thumbnailUploadCandidate = imageBlob
        sizeIndicator = thumbnailPreviewSection.querySelector(".admin-bigpanel-image-size-indicator")
        initializeSizeIndicator(sizeIndicator, imageBlob.size)
    else
        imagePreviewSection = croppingEditElement.querySelector(".admin-bigpanel-image-preview-section")
        imagePreview = imagePreviewSection.querySelector(".admin-bigpanel-image-preview")
        sizeIndicator = imagePreviewSection.querySelector(".admin-bigpanel-image-size-indicator")
        imagePreview.src = URL.createObjectURL(imageBlob)
        imageInformationMap[imageLabel].mainUploadCandidate = imageBlob
        initializeSizeIndicator(sizeIndicator, imageBlob.size)   

    killCroppie()
    return

cropButtonClicked = (event) ->
    log "cropButtonClicked"
    imageLabel = event.target.getAttribute("image-label")
    thumbnail = event.target.hasAttribute("thumbnail")
    log imageLabel    
    log thumbnail
    
    imageInfo = imageInformationMap[imageLabel]
    croppingEditElement = imageInfo.editElement 
    croppingEditElement.classList.add("cropping")

    cropSection = croppingEditElement.querySelector(".admin-bigpanel-crop-section")
    doCropButton = cropSection.querySelector(".admin-bigpanel-crop-button")
    doCropButton.setAttribute("image-label", imageLabel)
    doCropButton.setAttribute("thumbnail", thumbnail)

    cropElement = croppingEditElement.querySelector(".admin-bigpanel-crop-element")

    if thumbnail then candidate = imageInfo.thumbnailUploadCandidate
    else candidate = imageInfo.mainUploadCandidate
    if thumbnail
        thumbnailPreviewSection = croppingEditElement.querySelector(".admin-bigpanel-thumbnail-preview-section")
        sizeIndicator = thumbnailPreviewSection.querySelector(".admin-bigpanel-image-size-indicator")
        if sizeIndicator.innerText.length < 3 then imageSource = imageInfo.editElement.querySelector(".admin-bigpanel-image-preview")
        else imageSource = imageInfo.editElement.querySelector(".admin-bigpanel-thumbnail-preview")
    else imageSource = imageInfo.editElement.querySelector(".admin-bigpanel-image-preview")

    if candidate? then source = URL.createObjectURL(candidate)
    else source = imageSource.src
    # log source
    cropElement.src = source

    if thumbnail
        width = parseInt(imageInfo.info.thumbnail.width)
        height = parseInt(imageInfo.info.thumbnail.height)
    else
        width = parseInt(imageInfo.info.width)
        height = parseInt(imageInfo.info.height)
    # log width
    # log height

    options = 
        viewport: { width: width, height: height }
        boundary: { width: width+50, height: height+50}
        showZoomer: false

    currentCroppie = new Croppie(cropElement, options)
    try await currentCroppie.bind({zoom:0})
    catch err then log err
    return

uploadButtonClicked = (event) ->
    log "uploadButtonClicked"
    imageLabel = event.target.getAttribute("image-label")
    thumbnail = event.target.hasAttribute("thumbnail")
    if thumbnail then file = imageInformationMap[imageLabel].thumbnailUploadCandidate
    else file = imageInformationMap[imageLabel].mainUploadCandidate
    return unless file
    uploadFile(imageLabel, file, thumbnail)
    return

uploadFile = (label, file, thumbnail) ->
    log "uploadFile"
    formData = new FormData()
    formData.append(label, file)
    formData.append("thumbnail", thumbnail)

    token = appState.token()
    formData.append("token", token)
    
    langTag = pwaContent.languageTag
    formData.append("langTag", langTag)
    
    path = window.location.pathname
    documentName = path.split("/").pop() 
    formData.append("documentName", documentName)

    try
        await network.uploadImage(formData)
        bottomPanel.setSuccessMessage("Erfolgreich hochgeladen")
        location.reload()
    catch err 
        log err
        bottomPanel.setErrorMessage("Upload Failed!")
    return

#endregion

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
initializeSizeIndicator = (sizeIndicator, tobeSize) ->
    log "initializeSizeIndicator"
    try size = await tobeSize
    catch err then return
    sizeKB = 0.001 * parseFloat(size)
    pivotSizeKB = sizeIndicator.getAttribute("pivot-size")
    sizeIndicator.innerText = ""+sizeKB+"kb"
    
    sizeIndicator.classList.remove("lightweight")
    sizeIndicator.classList.remove("overweight")
    sizeIndicator.classList.remove("heavyweight")
    
    ## absolutes
    if sizeKB < 16
        sizeIndicator.classList.add("lightweight")
        return
    if sizeKB < 30 then return

    ## relative to specific pivot size
    if sizeKB < (pivotSizeKB / 2)
        sizeIndicator.classList.add("lightweight")
        return
    if sizeKB < (pivotSizeKB) then return
    if sizeKB < (pivotSizeKB * 2)
        sizeIndicator.classList.add("overweight")
        return

    sizeIndicator.classList.add("heavyweight")
    return

createImageEditElement = (label, image) ->
    log "createImageEditElement"
    div = document.createElement("div")
    innerHTML = getEditHeadHTML(image.name, label)
    innerHTML += getCropSectionHTML()
    innerHTML += getFileSelectionHTML()
    innerHTML += getMainImagePreviewHTML(image)
    if image.thumbnail?
        innerHTML += getThumbnailImagePreviewHTML(image)

    div.innerHTML = innerHTML
    leftArrow = div.querySelector(".admin-bigpanel-arrow-left")

    mainPreviewSection = div.querySelector(".admin-bigpanel-image-preview-section")
    mainPreview = mainPreviewSection.querySelector(".admin-bigpanel-image-preview")
    mainScaledCheckbox = mainPreviewSection.querySelector(".admin-bigpanel-view-all-checkbox")
    if mainScaledCheckbox? then mainScaledCheckbox.setAttribute("image-label", label)
    sizeIndicator = mainPreviewSection.querySelector(".admin-bigpanel-image-size-indicator")
    mainImageURL = "/img/"+image.name
    initializeSizeIndicator(sizeIndicator, network.getRessourceSize(mainImageURL))
    #cropButton
    cropButton = mainPreviewSection.querySelector(".admin-bigpanel-crop-button")
    cropButton.addEventListener("click", cropButtonClicked)
    cropButton.setAttribute("image-label", label)
    #uploadButton
    uploadButton = mainPreviewSection.querySelector(".admin-bigpanel-upload-button")
    uploadButton.addEventListener("click", uploadButtonClicked)
    uploadButton.setAttribute("image-label", label)

    if image.thumbnail?
        thumbnailPreviewSection = div.querySelector(".admin-bigpanel-thumbnail-preview-section")
        thumbnailPreview = thumbnailPreviewSection.querySelector(".admin-bigpanel-thumbnail-preview")
        thumbnailScaledCheckbox = thumbnailPreviewSection.querySelector(".admin-bigpanel-view-all-checkbox")
        if thumbnailScaledCheckbox? then thumbnailScaledCheckbox.setAttribute("image-label", label)
        #size indicator
        sizeIndicator = thumbnailPreviewSection.querySelector(".admin-bigpanel-image-size-indicator")
        thumbnailURL = "/img/"+image.thumbnail.name
        initializeSizeIndicator(sizeIndicator, network.getRessourceSize(thumbnailURL))
        #crop button
        cropButton = thumbnailPreviewSection.querySelector(".admin-bigpanel-crop-button")
        cropButton.addEventListener("click", cropButtonClicked)
        cropButton.setAttribute("image-label", label)
        cropButton.setAttribute("thumbnail", true)
        #upload button
        uploadButton = thumbnailPreviewSection.querySelector(".admin-bigpanel-upload-button")
        uploadButton.addEventListener("click", uploadButtonClicked)
        uploadButton.setAttribute("image-label", label)
        uploadButton.setAttribute("thumbnail", true)

    fileInput = div.querySelector(".admin-bigpanel-file-input")
    quitButton = div.querySelector(".admin-bigpanel-quit-button")
    cropSection = div.querySelector(".admin-bigpanel-crop-section")
    doCropButton = cropSection.querySelector(".admin-bigpanel-crop-button")
    
    div.classList.add("admin-bigpanel-edit-element")
    div.setAttribute("image-label", label)

    if mainScaledCheckbox? then mainScaledCheckbox.addEventListener("change", mainScaledCheckboxChanged)
    if thumbnailScaledCheckbox? then thumbnailScaledCheckbox.addEventListener("change", thumbnailScaledCheckboxChanged)


    leftArrow.setAttribute "image-label",label
    fileInput.setAttribute "name",label

    fileInput.addEventListener("change", fileInputChanged)
    quitButton.addEventListener("click", quitButtonClicked)
    doCropButton.addEventListener("click", doCropButtonClicked)

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
getCropSectionHTML = ->
    html = "<div class='admin-bigpanel-crop-section'>"
    html += "<div><img class='admin-bigpanel-crop-element'></div>"
    html += getCropFooterHTML()
    html += "</div>"
    return html

getCropFooterHTML = ->
    html = "<div class='admin-bigpanel-crop-footer'>"
    html += getQualityRangeHTML()
    html += getCropButtonHTML()
    html += getQuitButtonHTML()
    html += "</div>"
    return html

getQualityRangeHTML = ->
    html = "<div class='cr-slider-wrap'>"
    html += "<label>Qualität</label>"
    html += "<input type='range' class='cr-slider admin-bigpanel-crop-quality-range' "
    html += "min='0' max='1' step='0.05' value='0.65' >"
    html += "</div>"
    return html

getSizeIndicatorHTML =  (squarePixels) ->
    pivotSize = 0.0002 * squarePixels
    html = "<div class='admin-bigpanel-image-size-indicator' "
    html +="pivot-size='"+pivotSize+"' >"
    html += "</div>"
    return html

getImageDimensionHTML = (width, height) ->
    availableWidth = window.innerWidth - 100        
    html = "<div class='admin-bigpanel-image-dimension-section'>"
    html += "<div class='admin-bigpanel-image-dimension'>"
    html += width + " x " + height
    html += "</div>"
    if width > availableWidth
        html += "<div class='admin-bigpanel-view-all-section'>"
        html += "<input type='checkbox' class='admin-bigpanel-view-all-checkbox' "
        html += "scale-to-width='"+availableWidth+"' "
        scaledHeight = 1.0 * (availableWidth / width) * height
        html += "scale-to-height='"+scaledHeight+"' >"
        html += "<label class='admin-bigpanel-image-view-all-label'>Alles sehen</label>"
        html += "</div>"
    html += "</div>"
    return html

getEditHeadHTML = (name) ->
    html = "<div class='admin-bigpanel-edit-head'>"
    html += getArrowLeftHTML()
    html += "<div>"+name+"</div>"
    html += "</div>"
    return html

getFileSelectionHTML = ->
    html = "<div class='admin-bigpanel-file-selection-section'>"
    html += "<input type='file' "
    html += "class='admin-bigpanel-file-input'>"
    html += "</div>"
    return html

getMainImagePreviewHTML = (image) ->
    html = "<div class='admin-bigpanel-image-preview-section'>"
    html += getImageDimensionHTML(image.width, image.height)
    html += "<img class='admin-bigpanel-image-preview' "
    html += "src='/img/"+image.name+"' "
    html += "height='"+image.height
    html += "' width='"+image.width+"'>"
    html += getImageFooterHTML(image)
    html += "</div>"
    return html

getThumbnailImagePreviewHTML = (image) ->
    html = "<div class='admin-bigpanel-thumbnail-preview-section'>"
    html += getImageDimensionHTML(image.thumbnail.width, image.thumbnail.height)
    html += "<img class='admin-bigpanel-thumbnail-preview' "
    html += "src='/img/"+image.thumbnail.name+"' " 
    html += "height='"+image.thumbnail.height+"' "
    html += "width='"+image.thumbnail.width+"'>"
    html += getImageFooterHTML(image.thumbnail)
    html += "</div>"
    return html

getImageFooterHTML = (image) ->
    html = "<div class='admin-bigpanel-image-footer-section'>"
    html += getSizeIndicatorHTML(image.height * image.width)
    html += getCropButtonHTML()
    html += getUploadButtonHTML()
    html += "</div>"
    return html

############################################################
getArrowLeftHTML = ->
    html = "<div class='admin-bigpanel-arrow-left'>"
    html += "<svg><use href='#admin-svg-arrow-left-icon'></svg>"
    html += "</div>"
    return html

getQuitButtonHTML = ->
    html = "<div class='admin-bigpanel-quit-button'>" 
    html += "<svg><use href='#admin-svg-close-icon'></svg>"
    html += "</div>"
    return html

getCropButtonHTML = ->
    html = "<div class='admin-bigpanel-crop-button'>" 
    html += "crop!"
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
    log "imagemanagementmodule.setImages"
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

imagemanagementmodule.killCroppie = killCroppie
#endregion

module.exports = imagemanagementmodule