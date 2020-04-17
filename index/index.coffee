import Modules from "./allmodules"
import pwaContent from "./index-pwa-content.json"
import domconnect from "./indexdomconnect"

global.adminModules = Modules
global.adminInitialized = false

global.pwaContent = pwaContent

window.onload = ->
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
