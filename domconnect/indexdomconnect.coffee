indexdomconnect = {name: "indexdomconnect"}

############################################################
indexdomconnect.initialize = () ->
    global.adminPanel = document.getElementById("admin-panel")
    global.adminPanelVisibilityButton = document.getElementById("admin-panel-visibility-button")
    global.adminSecretInput = document.getElementById("admin-secret-input")
    global.adminLoginPreloader = document.getElementById("admin-login-preloader")
    global.adminMessageBox = document.getElementById("admin-message-box")
    global.adminBigpanel = document.getElementById("admin-bigpanel")
    global.adminMetaTabhead = document.getElementById("admin-meta-tabhead")
    global.adminImagesTabhead = document.getElementById("admin-images-tabhead")
    global.adminListsTabhead = document.getElementById("admin-lists-tabhead")
    global.adminLinksTabhead = document.getElementById("admin-links-tabhead")
    global.adminMetaTabcontent = document.getElementById("admin-meta-tabcontent")
    global.adminImagesTabcontent = document.getElementById("admin-images-tabcontent")
    global.adminListsTabcontent = document.getElementById("admin-lists-tabcontent")
    global.adminLinksTabcontent = document.getElementById("admin-links-tabcontent")
    global.adminFloatingpanel = document.getElementById("admin-floatingpanel")
    return
    
module.exports = indexdomconnect