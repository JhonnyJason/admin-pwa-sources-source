linkmanagementmodule = {name: "linkmanagementmodule"}
############################################################
#region printLogFunctions
log = (arg) ->
    if adminModules.debugmodule.modulesToDebug["linkmanagementmodule"]?  then console.log "[linkmanagementmodule]: " + arg
    return
ostr = (obj) -> JSON.stringify(obj, null, 4)
olog = (obj) -> log "\n" + ostr(obj)
print = (arg) -> console.log(arg)
#endregion

############################################################
contentHandler = null

############################################################
linkmanagementmodule.initialize = () ->
    log "linkmanagementmodule.initialize"
    contentHandler = adminModules.contenthandlermodule
    return


############################################################
createEditHTML = (label, content) ->
    log "createEditHTML"
    return "" unless typeof content == "string"
    html = "<div class='meta-edit-element'>"
    html += "<div class='meta-edit-label'>"
    html += label
    html += ":</div>"
    html += "<div text-content-key='"+label+".ref' contentEditable>"
    html += content
    html += "</div>"
    html += "</div>"
    return html

############################################################
findAllLinks = (prefix, contents) ->
    log "findAllLinks"
    allLinks = []
    for label,content of contents
        if typeof content == "object"
            if prefix then nextPrefix = prefix+"."+label
            else nextPrefix = label 
            allLinks.push(findAllLinks(nextPrefix, content))
        if label == "ref" and typeof content == "string"
            allLinks.push({ref:content, label:prefix})
    return allLinks.flat()


############################################################
linkmanagementmodule.getContentElement = ->
    log "linkmanagementmodule.getContentElement"
    element = document.createElement("div")
    contents = contentHandler.content()
    allLinks = findAllLinks("", contents)
    
    html = ""
    for link in allLinks 
        html += createEditHTML(link.label, link.ref)
    element.innerHTML = html
    return element

module.exports = linkmanagementmodule