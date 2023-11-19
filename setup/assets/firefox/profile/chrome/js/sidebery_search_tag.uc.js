// This is dependent on the sidebery-autohide.css being loaded

console.info("SideBery search tag script loaded!")

const sidebar_selector = '#sidebar-box[sidebarcommand="_3c078156-979c-498b-8990-85f7987dd929_-sidebar-action"]'
const panel_selector = 'panel[viewId="PanelUI-webext-_3c078156-979c-498b-8990-85f7987dd929_-BAV"]'

function panelCallback(entries) {
    const sidebar = document.querySelector(sidebar_selector)
    const panel = document.querySelector(panel_selector)

    const extension_sentinel = "extend"
    const extend_sidebar = Boolean(panel)

    if (sidebar) sidebar.setAttribute(extension_sentinel, extend_sidebar)
}

const toolbox = document.querySelector("toolbox#navigator-toolbox")
if (toolbox) {
    // console.debug('Toolbox found:', toolbox)
    const panelObserver = new MutationObserver(panelCallback)
    panelObserver.observe(toolbox, {subtree: true, childList: true})
}
