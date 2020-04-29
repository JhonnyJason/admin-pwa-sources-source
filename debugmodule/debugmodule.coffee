debugmodule = {name: "debugmodule", uimodule: false}

#####################################################
debugmodule.initialize = () ->
    # console.log "debugmodule.initialize - nothing to do"
    return

debugmodule.modulesToDebug = 
    unbreaker: true
    # adminmodule: true
    # adminpanelmodule: true
    # appstatemodule: true
    # authmodule: true
    # bigpanelmodule: true
    # bottompanelmodule: true
    # configmodule: true
    # contenthandlermodule: true
    # floatingpanelmodule: true
    # imagemanagementmodule: true
    # linkmanagementmodule: true
    listmanagementmodule: true
    # mustachekeysmodule: true
    # networkmodule: true
    # tabspanelmodule: true
    # templatepreparationmodule: true
    # uistatemodule: true

export default debugmodule
