templatepreparationmodule = {name: "templatepreparationmodule"}
############################################################
#region printLogFunctions
log = (arg) ->
    if adminModules.debugmodule.modulesToDebug["templatepreparationmodule"]?  then console.log "[templatepreparationmodule]: " + arg
    return
ostr = (obj) -> JSON.stringify(obj, null, 4)
olog = (obj) -> log "\n" + ostr(obj)
print = (arg) -> console.log(arg)
#endregion

############################################################
decamelize = require "decamelize"

############################################################
templatepreparationmodule.initialize = () ->
    log "templatepreparationmodule.initialize"
    return

############################################################
prepareAllTexts = (domBody) ->
    log "prepareAllTexts"
    children = domBody.children
    log '@Body we have ' + children.length + ' children!'
    prepareTextNode child for child in children #when !($(child).is('script'))
    return

prepareTextNode = (node) ->
    log "prepareNode"
    return unless hasText(node)
    
    children = node.children
    if children.length == 0
        # log "-----"
        log "found leaf at " + node.tagName + " " + node.id
        # log cheerioNode.text()
        textContentKey = node.textContent.replace(/{/g, "").replace(/}/g, "").replace(/\s/g, "")
        log textContentKey
        node.setAttribute("text-content-key", textContentKey)
        node.setAttribute("contentEditable", true)
        return

    prepareTextNode child for child in children #when !($(child).is('script'))
    return

hasText = (node) ->
    log node
    text = node.textContent
    log text
    if text then text = text.replace(/\s/g, '')
    if text then return true
    return false

############################################################
prepareAllImages = (domBody) ->
    log "prepareAllImages"
    allImages = Object.keys(pwaContent.images)
    prepareImage(image, domBody) for image in allImages
    return

prepareImage = (camelizedId, domBody) ->
    log "prepareImage"
    log camelizedId
    imageId = decamelize(camelizedId, "-")
    log imageId
    imageElement = domBody.querySelector("#"+imageId)
    imageElement.setAttribute("image-content-key", camelizedId)
    return

############################################################
templatepreparationmodule.prepareBody = (domBody) ->
    log "prepareBody"
    prepareAllTexts(domBody)
    # prepareAllLinks($,cheerioBody, content)
    prepareAllImages(domBody)
    # prepareAllLists($, cheerioBody, content)
    
    return

module.exports = templatepreparationmodule

# ############################################################
# prepareAllLists = ($, cheerioBody, content) ->
#     log "prepareAllLists"
#     allListKeys = searchArrays("sharedContent", content.sharedContent)
#     allListKeys = allListKeys.concat(searchArrays("content", content.content))
#     for listKey in allListKeys
#         prepareList($, cheerioBody, content, listKey)
#     return

# searchArrays = (prefix, obj) ->
#     log "searchArrays"
#     if typeof obj != "object" then return
#     result = []
#     for key,sub of obj
#         newResults = searchArrays(prefix+"."+key, sub)
#         if !newResults then continue
#         if Array.isArray(sub) then newResults.push(prefix+"."+key)
#         result = result.concat(newResults)
#     return result


# prepareList = ($, cheerioBody, content, listKey) ->
#     log "prepareList"
#     keyTokens = listKey.split(".")
#     token = keyTokens.shift()
#     listObject = content[token]
#     listObject = listObject[token] for token in keyTokens
#     if typeof listObject[0] == "string" then prepareTextList($, cheerioBody,listKey)
#     else prepareObjectList($, cheerioBody, listKey, listObject)
#     return

# prepareTextList = ($, cheerioBody, listKey) ->
#     log "prepareTextList"
#     selector = "[text-content-key='"+listKey+".0']"
#     log selector
#     firstElement = cheerioBody.find(selector).first()
#     listParent = firstElement.parent()
#     listParent.attr("list-content-key", listKey)
#     return

# prepareObjectList = ($, cheerioBody, listKey, listObject) ->
#     log "prepareObjectList"
#     return

# ############################################################
# prepareAllLinks = ($, cheerioBody) ->
#     log "prepareAllLinks"
#     allLinks = cheerioBody.find("a")
#     log allLinks.length
#     prepareLinkNode $,link for link in allLinks when isContentLink($,link)
#     return

# isContentLink = ($, link) ->
#     log "isContentLink"
#     cheerioLink = $(link)
#     href = cheerioLink.attr("href")
#     identifier = ".ref}}}"
#     index = href.lastIndexOf(identifier)
#     return index == (href.length - identifier.length)

# prepareLinkNode = ($, link) ->
#     log "prepareLinkNode"
#     cheerioLink = $(link)
#     linkContentKey = cheerioLink.attr("href").replace(/{/g, "").replace(/}/g, "")
#     cheerioLink.attr("link-content-key", linkContentKey)
#     return
