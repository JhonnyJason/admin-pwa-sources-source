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
    if element.tagName == "A"
        href = element.getAttribute("href")
        realLink = "<a href='"+href+"'>activate Link</a>"
        adminFloatingpanel.innerHTML = realLink
    else
        adminFloatingpanel.style.width = element.getBoundingClientRect().width+"px"   
    return

floatingpanelmodule.appear = (left, bottom) ->
    log "floatingpanelmodule.appear"
    if disappearTimemoutId then clearTimeout(disappearTimemoutId)
    disappearTimemoutId = 0
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