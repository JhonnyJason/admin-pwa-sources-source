floatingpanelmodule = {name: "floatingpanelmodule"}
############################################################
#region printLogFunctions
log = (arg) ->
    if adminModules.debugmodule.modulesToDebug["floatingpanelmodule"]?  then console.log "[floatingpanelmodule]: " + arg
    return
ostr = (obj) -> JSON.stringify(obj, null, 4)
olog = (obj) -> log "\n" + ostr(obj)
print = (arg) -> console.log(arg)
#endregion

############################################################
admin = null

############################################################
#region internalProperties
disappearTimemoutId = 0
timeoutMS = 200
unused = true

############################################################
#region linkEditing
currentLinkFallback = ""
currentLabelFallback = ""
links = []
element = null
elementContentFallback = ""
#endregion

#endregion

############################################################
floatingpanelmodule.initialize = () ->
    log "floatingpanelmodule.initialize"
    admin = adminModules.adminmodule

    adminFloatingpanel.addEventListener("focusin", onFocus)
    adminFloatingpanel.addEventListener("focusout", floatingpanelmodule.disappear)
    return

############################################################
disappear = ->
    log "disappear"
    adminFloatingpanel.classList.remove("active")
    return

onFocus = ->
    log "onFocus"
    if disappearTimemoutId then clearTimeout(disappearTimemoutId)
    disappearTimemoutId = 0
    return

############################################################
createLinkDisplayHTML = (index) ->
    log "createLinkDisplayHTML"
    href = links[index].getAttribute("href")
    html = "<div class='link-display'>"
    html += "<div class='link-display-top'>"
    html += "<div class='link-text' "
    html += "link-index='"+index+"' >"
    html += links[index].innerText
    html += "</div>"
    html += "<a href='"+href+"'>"
    html += "activate Link"
    html += "</a>"
    html += "</div>"
    html += "<div class='link-display-lower'>"
    html += "<input type='text' value='"+href+"' "
    html += "link-index='"+index+"' >"
    html += "</div>"
    html += "</div>"
    return html

createSublinksDisplay = ->
    log "createSublinkDisplay"
    html = "<div>"
    for link,index in links
        html += createLinkDisplayHTML(index)
    html += "</div>" 
    return html

############################################################
#region linkEditingFunctions
labelEditingStarted = (event) ->
    log "labelEditingStarted"
    currentLabelFallback = this.innerText
    return

labelEditingStopped = (event) ->
    log "labelEditingStopped"
    newText = this.innerText
    return if newText == currentLabelFallback

    index = this.getAttribute("link-index")
    link = links[index]
    link.innerText = newText
    admin.noticeElementEdit(element, elementContentFallback)
    return

labelKeyPressed = (event) ->
    log "labelKeyPressed"
    key = event.keyCode
    if (key == 27) #escape
        this.innerText = currentLabelFallback
        document.activeElement.blur()
    return

############################################################
linkEditingStarted = (event) ->
    log "linkEditingStarted"
    currentLinkFallback = this.value
    return

linkEditingStopped = (event) ->
    log "linkEditingStopped"
    newLink = this.value
    return if newLink == currentLinkFallback
    index = this.getAttribute("link-index")
    link = links[index]
    link.setAttribute("href", newLink)
    admin.noticeElementEdit(element, elementContentFallback)
    return

linkKeyPressed = (event) ->
    log "linkKeyPressed"
    key = event.keyCode
    if (key == 27) #escape
        this.value = currentLinkFallback
        document.activeElement.blur()

    return

#endregion

############################################################
addLinkManagementListeners = ->
    log "addLinkManagementListeners"
    linkLabels = adminFloatingpanel.getElementsByClassName("link-text")
    for label in linkLabels
        label.setAttribute("contenteditable",true)
        label.addEventListener("focusin", labelEditingStarted)
        label.addEventListener("focusout", labelEditingStopped)
        label.addEventListener("keypress", labelKeyPressed)
    linkInputs = adminFloatingpanel.getElementsByTagName("INPUT")
    for input in linkInputs
        input.addEventListener("focusin", linkEditingStarted)
        input.addEventListener("focusout", linkEditingStopped)
        input.addEventListener("keypress", linkKeyPressed)
    return


############################################################
floatingpanelmodule.initializeForElement = (targetElement, contentFallback) ->
    log "floatingpanelmodule.initializeForElement"
    unused = false
    adminFloatingpanel.innerHTML = ""
    element = targetElement
    log ""+element
    elementContentFallback = ""+contentFallback
    if element.tagName == "A"
        href = element.getAttribute("href")
        realLink = "<a href='"+href+"'>activate Link</a>"
        adminFloatingpanel.innerHTML = realLink
        log "identified used"
        return

    links = element.getElementsByTagName("A")
    if links.length > 0
        adminFloatingpanel.innerHTML = createSublinksDisplay()
        addLinkManagementListeners()
        log "identified used"
        return

    log "identified unused"
    unused = true
    return

floatingpanelmodule.appear = (left, bottom) ->
    log "floatingpanelmodule.appear"
    if disappearTimemoutId then clearTimeout(disappearTimemoutId)
    disappearTimemoutId = 0
    return if unused
    adminFloatingpanel.classList.add("active")
    adminFloatingpanel.style.left = left+"px"
    adminFloatingpanel.style.bottom = bottom+"px"
    return

floatingpanelmodule.disappear = ->
    log "floatingpanelmodule.disappear"
    if disappearTimemoutId then clearTimeout(disappearTimemoutId)
    disappearTimemoutId = setTimeout(disappear, timeoutMS)
    return

module.exports = floatingpanelmodule