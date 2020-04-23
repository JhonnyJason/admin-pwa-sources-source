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
disappearTimemoutId = 0
timeoutMS = 200
unused = true

############################################################
floatingpanelmodule.initialize = () ->
    log "floatingpanelmodule.initialize"
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

createLinkDisplayHTML = (element, link) ->
    log "createLinkDisplayHTML"
    href = link.getAttribute("href")
    html = "<div class='link-display'>"
    html += "<div class='link-display-top'>"
    html += "<div class='link-text'>"
    html += link.textContent
    html += "</div>"
    html += "<a href='"+href+"'>"
    html += "activate Link"
    html += "</a>"
    html += "</div>"
    html += "<div class='link-display-lower'>"
    html += "<input type='text' value='"+href+"' >"
    html += "</div>"
    html += "</div>"
    return html

createSublinkDisplay = (element, subLinks) ->
    log "createSublinkDisplay"
    html = "<div>"
    for link in subLinks
        html += createLinkDisplayHTML(element, link)
    html += "</div>" 
    return html

############################################################
floatingpanelmodule.initializeForElement = (element) ->
    log "floatingpanelmodule.initializeForElement"
    unused = false
    if element.tagName == "A"
        href = element.getAttribute("href")
        realLink = "<a href='"+href+"'>activate Link</a>"
        adminFloatingpanel.innerHTML = realLink
        log "identified used"
        return

    subLinks = element.querySelectorAll("a")
    if subLinks.length > 0
        adminFloatingpanel.innerHTML = createSublinkDisplay(element, subLinks)
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