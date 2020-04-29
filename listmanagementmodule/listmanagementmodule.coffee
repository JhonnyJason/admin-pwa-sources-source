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

############################################################
allLists = null
listInformationMap = {}

############################################################
listmanagementmodule.initialize = ->
    log "listmanagementmodule.initialize"
    admin = adminModules.adminmodule
    bigpanel = adminModules.bigpanelmodule
    bottomPanel = adminModules.bottompanelmodule
    return

############################################################
addButtonClicked = (event) ->
    log "addButtonClicked"
    listId = event.target.getAttribute("list-id")
    log listId
    list = allLists[listId]
    newList = JSON.parse(JSON.stringify(list))
    newList.push JSON.parse(JSON.stringify(list[0]))
    olog newList
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
    log listId
    newList = JSON.parse(JSON.stringify(list))
    
    thisElement = newList[index]
    nextElement = newList[nextIndex]
    newList[nextIndex] = thisElement
    newList[index] = nextElement

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
    log listId
    newList = JSON.parse(JSON.stringify(list))
    
    thisElement = newList[index]
    prevElement = newList[prevIndex]
    newList[prevIndex] = thisElement
    newList[index] = prevElement
    
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
    html = "<div class='admin-bigpanel-list-item'>"
    html += getItemPreviewHTML(item)
    html += getItemControlHTML(index, listId)
    html += "</div>"
    return html


############################################################
getItemPreviewHTML = (item) ->
    html = "<div class='admin-bigpanel-list-item-preview'>"
    if typeof item == "string" then html += item
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