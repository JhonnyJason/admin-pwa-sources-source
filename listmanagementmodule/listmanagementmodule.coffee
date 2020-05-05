listmanagementmodule = {name: "listmanagementmodule"}
############################################################
#region printLogFunctions
log = (arg) ->
    if adminModules.debugmodule.modulesToDebug["listmanagementmodule"]?  then console.log "[listmanagementmodule]: " + arg
    return
ostr = (obj) -> JSON.stringify(obj, null, 4)
olog = (obj) -> log "\n" + ostr(obj)
print = (arg) -> console.log(arg)
#endregion

############################################################
admin = null
bigpanel = null
bottomPanel = null
contentHandler = null

############################################################
allLists = null
listInformationMap = {}

############################################################
listmanagementmodule.initialize = ->
    log "listmanagementmodule.initialize"
    admin = adminModules.adminmodule
    bigpanel = adminModules.bigpanelmodule
    bottomPanel = adminModules.bottompanelmodule
    contentHandler = adminModules.contenthandlermodule
    return

############################################################
findURLsOfListItem = (listItem) ->
    log "findURLsOfListItem"
    urls = []
    for label,element of listItem
        if label == "url" then urls.push(element)
        if typeof element == "object" then urls.push(findURLsOfListItem(element))
    return urls.flat()

findImageObject = (name) ->
    log "findImageObject"
    content = contentHandler.content()
    for label,image of content.images
        if image.name == name then return { label, image }
    return

findAssociatedImageKey = (url) ->
    log "findAssociatedImageKey"
    imageObject = findAssetObject(url)
    if !imageObject or !imageObject.label 
        console.log(url + " did not have an image object")
        return ""
    return imageObject.label

findAssetObject = (url) ->
    log "findAssetObject"
    tokens = url.split("/")
    if tokens.length < 2 then return null
    if tokens[0] == "img" then return findImageObject(tokens[1])
    if tokens.length < 3 then return null
    if tokens[1] == "img" then return findImageObject(tokens[2])
    return

findAssetObjects = (urlList) ->
    log "findAssetObjects"
    assetObjects = []
    for url in urlList
        assetObjects.push(findAssetObject(url))
    return assetObjects

############################################################
adjustAssetIndicesTo = (assetObjects, index) ->
    log "adjustAssetIndicesTo"
    newKey = ""+(index+1)
    assetObjects = JSON.parse(JSON.stringify(assetObjects))
    for assetObject in assetObjects
        assetObject.label = assetObject.label.replace("1", newKey)
        if assetObject.image
            assetObject.image.name = assetObject.image.name.replace("1", newKey)
            if assetObject.image.thumbnail
                assetObject.image.thumbnail.name = assetObject.image.thumbnail.name.replace("1", newKey)
    return assetObjects

adjustURLIndicesTo = (item, index) ->
    log "adjustURLIndicesTo"
    newKey = ""+(index+1)
    for label,element of item
        if label == "url" then item[label] = element.replace("1", newKey)
        if typeof element == "object" then adjustURLIndicesTo(element, index)
    return

adjustURLIndicesFromTo = (item, fromIndex, toIndex) ->
    log "adjustURLIndicesFromTo"
    oldKey = ""+(fromIndex+1)
    newKey = ""+(toIndex+1)
    for label,element of item
        if label == "url" then item[label] = element.replace(oldKey, newKey)
        if typeof element == "object" then adjustURLIndicesFromTo(element, fromIndex, toIndex)
    return

adjustURLIndicesOneDown = (list, index) ->
    log "adjustURLIndicesOneDown"
    while index < list.length
        adjustURLIndicesFromTo(list[index], index+1, index)
        index++
    return

############################################################
createNewListItem = (templateEntry, index) ->
    log "createNewListItem"
    item = JSON.parse(JSON.stringify(templateEntry))
    urlList = findURLsOfListItem(item)
    assetObjects = findAssetObjects(urlList)
    # olog assetObjects
    adjustURLIndicesTo(item, index)
    adjustedObjects = adjustAssetIndicesTo(assetObjects, index)
    # olog assetObjects
    if adjustedObjects
        content = contentHandler.content()
        oldImages = JSON.parse(JSON.stringify(content.images))
        for label,element of adjustedObjects
            if element.image
                content.images[element.label] = element.image
        admin.noticeImagesEdits(oldImages)
    # olog assetEdits
    # olog item
    return item

removeAssociatedAssets = (firstItem, index, lastIndex) ->
    log "removeAssociatedAssets"
    urlList = findURLsOfListItem(firstItem)
    assetObjects = findAssetObjects(urlList)
    if assetObjects
        adjustedObjects = adjustAssetIndicesTo(assetObjects, lastIndex)
        content = contentHandler.content()
        oldImages = JSON.parse(JSON.stringify(content.images))
        for label,element of adjustedObjects
            if element.image
                delete content.images[element.label]
        
        imageMoves = createDeleteMoves(assetObjects, index, lastIndex)
        admin.noticeImageSwaps(imageMoves)
        admin.noticeImagesEdits(oldImages)
    return

createDeleteMoves = (assetObjects, index, lastIndex) ->
    log "createDeleteMoves"
    moves = []
    walker = index
    while walker < lastIndex
        walker = walker + 1
        fromObjects = adjustAssetIndicesTo(assetObjects, walker)
        olog fromObjects
        toObjects = adjustAssetIndicesTo(assetObjects, walker-1)
        olog toObjects
        for label of fromObjects
            if fromObjects[label].image
                fromName = fromObjects[label].image.name
                toName = toObjects[label].image.name
                moves.push {fromName, toName}
                if fromObjects[label].image.thumbnail
                    fromName = fromObjects[label].image.thumbnail.name
                    toName = toObjects[label].image.thumbnail.name
                    moves.push {fromName, toName}
    olog moves
    return moves

createSwapMoves = (firstItem, fromIndex, toIndex) ->
    log "createSwapMoves"
    moves = []
    urlList = findURLsOfListItem(firstItem)
    assetObjects = findAssetObjects(urlList)
    fromObjects = adjustAssetIndicesTo(assetObjects, fromIndex)
    olog fromObjects
    toObjects = adjustAssetIndicesTo(assetObjects, toIndex)
    olog toObjects

    for label of fromObjects
        if fromObjects[label].image
            fromName = fromObjects[label].image.name
            toName = "temp-"+fromObjects[label].image.name
            moves.push {fromName, toName}
            if fromObjects[label].image.thumbnail
                fromName = fromObjects[label].image.thumbnail.name
                toName = "temp-"+fromObjects[label].image.thumbnail.name
                moves.push {fromName, toName}

    for label of fromObjects
        if fromObjects[label].image
            fromName = toObjects[label].image.name
            toName = fromObjects[label].image.name
            moves.push {fromName, toName}
            if fromObjects[label].image.thumbnail
                fromName = toObjects[label].image.thumbnail.name
                toName = fromObjects[label].image.thumbnail.name
                moves.push {fromName, toName}

    for label of fromObjects
        if fromObjects[label].image
            fromName = "temp-"+fromObjects[label].image.name
            toName = toObjects[label].image.name
            moves.push {fromName, toName}
            if fromObjects[label].image.thumbnail
                fromName = "temp-"+fromObjects[label].image.thumbnail.name
                toName = toObjects[label].image.thumbnail.name
                moves.push {fromName, toName}

    olog moves
    return moves

############################################################
addButtonClicked = (event) ->
    log "addButtonClicked"
    listId = event.target.getAttribute("list-id")
    log listId
    list = allLists[listId]
    newList = JSON.parse(JSON.stringify(list))
    newItem = createNewListItem(list[0], list.length)
    newList.push newItem
    # olog newList
    admin.noticeListEdit(listId, newList, list)
    return

downButtonClicked = (event) ->
    log "downButtonClicked"
    listId = event.target.getAttribute("list-id")
    index = parseInt(event.target.getAttribute("index"))
    list = allLists[listId]
    nextIndex = index + 1
    log index
    log nextIndex
    if nextIndex >= list.length
        bottomPanel.setErrorMessage("Das letzte Element kann nicht nach unten verschoben werden!")
        return
    # log listId
    # olog list
    newList = JSON.parse(JSON.stringify(list))
    
    thisElement = newList[index]
    nextElement = newList[nextIndex]
    newList[nextIndex] = thisElement
    newList[index] = nextElement

    adjustURLIndicesFromTo(newList[nextIndex], index, nextIndex)
    adjustURLIndicesFromTo(newList[index], nextIndex, index)

    imageMoves = createSwapMoves(list[0], index, nextIndex)
    admin.noticeImageSwaps(imageMoves)
    admin.noticeListEdit(listId, newList, list)
    return 

upButtonClicked = (event) ->
    log "upButtonClicked"
    listId = event.target.getAttribute("list-id")
    index = parseInt(event.target.getAttribute("index"))
    list = allLists[listId]
    prevIndex = index - 1
    log index
    log prevIndex
    if prevIndex < 0
        bottomPanel.setErrorMessage("Das erste Element kann nicht nach oben verschoben werden!")
        return
    # log listId
    # olog list
    newList = JSON.parse(JSON.stringify(list))
    
    thisElement = newList[index]
    prevElement = newList[prevIndex]
    newList[prevIndex] = thisElement
    newList[index] = prevElement
    
    adjustURLIndicesFromTo(newList[prevIndex], index, prevIndex)
    adjustURLIndicesFromTo(newList[index], prevIndex, index)

    imageMoves = createSwapMoves(list[0], index, prevIndex)
    admin.noticeImageSwaps(imageMoves)

    admin.noticeListEdit(listId, newList, list)    
    return

deleteButtonClicked = (event) ->
    log "deleteButtonClicked"
    listId = event.target.getAttribute("list-id")
    index = parseInt(event.target.getAttribute("index"))
    list = allLists[listId]
    log listId
    log index
    if list.length == 1
        bottomPanel.setErrorMessage("Das letzte Element kann nicht gelöscht werden!")
        return
    newList = JSON.parse(JSON.stringify(list))
    newList.splice(index, 1)
    removeAssociatedAssets(list[0], index, newList.length)
    # olog newList
    # olog index
    adjustURLIndicesOneDown(newList, index)
    # olog newList
    admin.noticeListEdit(listId, newList, list)    
    return

############################################################
createListEditElement = (listId, list) ->
    # log "createImageEditElement"
    div = document.createElement("div")

    innerHTML = getEditHeadHTML(listId)
    for listItem,index in list
        innerHTML += getListItemHTML(listItem, index, listId)
    innerHTML += getAddButtonHTML(listId)

    div.innerHTML = innerHTML

    leftArrow = div.querySelector(".admin-bigpanel-arrow-left")
    addButton = div.querySelector(".admin-bigpanel-add-button")
    upButtons = div.querySelectorAll(".admin-bigpanel-up-button")
    downButtons = div.querySelectorAll(".admin-bigpanel-down-button")
    deleteButtons = div.querySelectorAll(".admin-bigpanel-delete-button")

    div.classList.add("admin-bigpanel-edit-element")
    div.setAttribute "list-id",listId
    leftArrow.setAttribute "list-id",listId
    addButton.setAttribute "list-id",listId
    addButton.addEventListener("click", addButtonClicked)

    for button in upButtons
        button.setAttribute "list-id",listId
        button.addEventListener("click", upButtonClicked)
    for button in downButtons
        button.setAttribute "list-id",listId
        button.addEventListener("click", downButtonClicked)
    for button in deleteButtons
        button.setAttribute "list-id",listId
        button.addEventListener("click", deleteButtonClicked)

    return div

createListListElement = (listId, list) ->
    # log "createImageListElement"
    div = document.createElement("div")
    innerHTML = "<div>"+listId+"</div>"
    innerHTML += getArrowRightHTML()
    div.innerHTML = innerHTML
    div.classList.add("admin-bigpanel-list-element")
    div.setAttribute "list-id",listId
    return div

############################################################
#region createElementHelpers
getEditHeadHTML = (name) ->
    html = "<div class='admin-bigpanel-edit-head'>"
    html += getArrowLeftHTML()
    html += "<div>"+name+"</div>"
    html += "</div>"
    return html

getListItemHTML = (item, index, listId) ->
    listItemKey = listId+"."+index
    html = "<div class='admin-bigpanel-list-item'>"
    html += getItemPreviewHTML(item, listItemKey)
    html += getItemControlHTML(index, listId)
    html += "</div>"
    return html


############################################################
getItemPreviewHTML = (item, key) ->
    html = ""
    if typeof item == "string"
        html += "<div class='admin-bigpanel-list-item-preview' "
        html += "text-content-key='"+key+"' contentEditable='true'>"
        html += item
        html += "</div>"
    else
        # olog key
        # olog item
        html += "<div class='admin-bigpanel-list-item-preview' >"
        url = item["thumbnailURL"]
        urlKey = key+".thumbnailURL"
        if !url
            url = item["url"]
            urlKey = key+".url"
        if url
            imageKey = findAssociatedImageKey(url)
            html += "<img src='"+url+"' "
            html += "image-content-key='"+imageKey+"' >"
            # html += "<div text-content-key='"+urlKey+"' contentEditable='true'>"
            # html += url
            # html += "</div>"
        else
            for label,itemContent of item
                if typeof itemContent == "string"
                    contentKey = key+"."+label
                    html += "<div text-content-key='"+contentKey+"' contentEditable='true'>"
                    html += itemContent
                    html += "</div>"
                    break
        html += "</div>"
    return html

getItemControlHTML = (index, listId)->
    html = "<div class='admin-bigpanel-list-item-control'>"
    html += getUpButtonHTML(index, listId)
    html += getDeleteButtonHTML(index, listId)
    html += getDownButtonHTML(index, listId)
    html += "</div>"
    return html

############################################################
getAddButtonHTML = ->
    html = "<div class='admin-bigpanel-add-button'>"
    html += "<svg><use href='#admin-svg-add-icon'></svg>"
    html += "</div>"
    return html

getUpButtonHTML = (index, listId) ->
    html = "<div class='admin-bigpanel-up-button' "
    html += "index='"+index+"' "
    html += "list-id='"+listId+"' "
    html += ">"
    html += "<svg><use href='#admin-svg-arrow-up-icon'></svg>"
    html += "</div>"
    return html

getDownButtonHTML = (index, listId) ->
    html = "<div class='admin-bigpanel-down-button' "
    html += "index='"+index+"' "
    html += "list-id='"+listId+"' "
    html += ">"
    html += "<svg><use href='#admin-svg-arrow-down-icon'></svg>"
    html += "</div>"
    return html

getDeleteButtonHTML = (index, listId) ->
    html = "<div class='admin-bigpanel-delete-button' "
    html += "index='"+index+"' "
    html += "list-id='"+listId+"' "
    html += ">"
    html += "<svg><use href='#admin-svg-delete-icon'></svg>"
    html += "</div>"
    return html

############################################################
getArrowLeftHTML = ->
    html = "<div class='admin-bigpanel-arrow-left'>"
    html += "<svg><use href='#admin-svg-arrow-left-icon'></svg>"
    html += "</div>"
    return html

############################################################
getArrowRightHTML = ->
    html = "<div class='admin-bigpanel-arrow-right'>"
    html += "<svg><use href='#admin-svg-arrow-right-icon'></svg>"
    html += "</div>"
    return html

#endregion

addList = (listId, list) ->
    # log "addList"
    allLists[listId] = list
    listInformationMap[listId] = {}
    listInfo = listInformationMap[listId]
    listInfo.id = listId
    listInfo.list = list
    listInfo.editElement = createListEditElement(listId, list)
    listInfo.listElement = createListListElement(listId, list)
    return

digestToLists = (prefix, content) ->
    # log "digestToLists"
    if Array.isArray(content) then addList(prefix, content)
    if prefix then nextPrefix = prefix+"."
    else nextPrefix = prefix

    for label,element of content
        if typeof element == "object" then digestToLists(nextPrefix+label, element)
    return

############################################################
#region exposedFunctions
listmanagementmodule.setNewList = (list, listId) ->
    log "listmanagementmodule.setNewList"
    allLists[listId] = list
    return

listmanagementmodule.prepareListElements = (content) ->
    log "listmanagementmodule.prepareListElements"
    allLists = {}
    digestToLists("",content)
    return

listmanagementmodule.getListElement = (listId) ->
    # log "listmanagementmodule.getListElement"
    return unless listInformationMap[listId]
    return listInformationMap[listId].listElement
    return

listmanagementmodule.getEditElement = (listId) ->
    # log "listmanagementmodule.getEditElement"
    return unless listInformationMap[listId]
    return listInformationMap[listId].editElement
    return

listmanagementmodule.elementExists = (listId) ->
    # log "listmanagementmodule.elementExists"
    # log listId
    if !listInformationMap[listId] then return false
    # id = listInformationMap[listId].id
    # if !document.getElementById(id) then return false
    # log "does exist"
    return true

listmanagementmodule.getLists = -> allLists

#endregion

module.exports = listmanagementmodule