import Modules from "./allmodules"
import domconnect from "./indexdomconnect"

global.adminModules = Modules
global.adminInitialized = false

otherDocumentLoad = window.onload
window.onload = ->
    otherDocumentLoad()
    console.log("Admin Index - OnLoad!")
    return if global.adminInitialized
    domconnect.initialize()
    promises = (m.initialize() for n,m of Modules)
    await Promise.all(promises)
    global.adminInitialized = true
    adminStartup()


adminStartup = ->
    Modules.authmodule.tokenCheck()
    Modules.adminmodule.start()
    return
