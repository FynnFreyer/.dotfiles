// Set a sentinel value on the sidebery sidebar on tab search, to trigger its
// extension via CSS. This is dependent on sidebery-autohide.css being loaded.


function setup () {
    console.info("SideBery search tag script loaded!")

    // the panel is opened when activating the search
    const panel_selector = 'panel[viewId="PanelUI-webext-_3c078156-979c-498b-8990-85f7987dd929_-BAV"]'
    // the sidebar should be expanded when searching
    const sidebar_selector = '#sidebar-box[sidebarcommand="_3c078156-979c-498b-8990-85f7987dd929_-sidebar-action"]'

    // callback to set the sentinel attribute
    function panelCallback(entries) {
        const sidebar = document.querySelector(sidebar_selector)
        const panel = document.querySelector(panel_selector)

        const extension_sentinel = "extend"
        const extend_sidebar = Boolean(panel)

        if (sidebar) sidebar.setAttribute(extension_sentinel, extend_sidebar)
    }

    // the toolbox holds the search panel
    const toolbox = document.querySelector("toolbox#navigator-toolbox")
    if (toolbox) {
        // console.debug('Toolbox found:', toolbox)
        const panelObserver = new MutationObserver(panelCallback)
        panelObserver.observe(toolbox, {subtree: true, childList: true})
    }
}

setup()

