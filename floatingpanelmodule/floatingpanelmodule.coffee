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
unsused = true

############################################################
floatingpanelmodule.initialize = () ->
    log "floatingpanelmodule.initialize"
    return

############################################################
disappear = ->
    log "disappear"
    adminFloatingpanel.classList.remove("active")
    return

############################################################
floatingpanelmodule.initializeForElement = (element) ->
    log "floatingpanelmodule.initializeForElement"
    unused = false
    if element.tagName == "A"
        href = element.getAttribute("href")
        realLink = "<a href='"+href+"'>activate Link</a>"
        adminFloatingpanel.innerHTML = realLink
    else
        unused = true
    return

floatingpanelmodule.appear = (left, bottom) ->
    log "floatingpanelmodule.appear"
    if disappearTimemoutId then clearTimeout(disappearTimemoutId)
    disappearTimemoutId = 0
    return if unsused
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