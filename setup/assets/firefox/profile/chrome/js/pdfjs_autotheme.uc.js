console.info('PDF.js auto theming script loaded!')

// better solved in userstyle, just keeping this around as "on page-visit" code example for now

const {PlacesUtils} = ChromeUtils.importESModule("resource://gre/modules/PlacesUtils.sys.mjs");

const bg_color = "#cfcfd8"

function setPdfThemeLight(viewer) {
    console.debug("Setting light theme on viewer:", viewer)
    viewer.style.filter = "grayscale(0) invert(0) sepia(0) contrast(100%)"
    viewer.style.backgroundColor = bg_color
}

function setPdfThemeDark(viewer) {
    console.debug("Setting dark theme on viewer:", viewer)
    viewer.style.filter = "grayscale(1) invert(1) sepia(1) contrast(75%)"
    // same color as light bc. of inversion
    viewer.style.backgroundColor = bg_color
}

function setTheme(viewer) {
    const darkQuery = window.matchMedia("(prefers-color-scheme: dark)")
    if (darkQuery.matches) setPdfThemeDark(viewer)
    else setPdfThemeLight(viewer)

    console.debug("Set theme on viewer")
}

let listener = events => {
    for (const event of events) {
        console.debug("Listener triggered for event:", event)
        const viewer = document.querySelector("div#viewer.pdfViewer")
        if (viewer) {
            console.debug("PDF viewer found:", viewer)
            setTheme(viewer)
        } else {
            console.debug("No PDF viewer found")
        }
    }
}

console.debug("DATA START .......................................................")
console.debug("this", this)


if (typeof gBrowser === "undefined") {
    if (window._gBrowser) {
        console.debug("window._gBrowser", window._gBrowser)
    } else {
        let variables = []
        for (const name in this)
            variables.push(name)

        console.debug(variables)
    }
} else {
    console.debug("gBrowser", gBrowser)
    console.debug("contentWindow", gBrowser.contentWindow)
    // let foo = gBrowser.contentWindow.confirm("Hello from browser chrome...")
    // console.debug(foo)
}

const browsers = document.querySelectorAll(("browser"))
if (browsers) {
    console.debug("browsers", browsers)
}

const panels = document.querySelectorAll(("tabpanels"))
if (panels) {
    console.debug("panels", panels)
}

console.debug("PlacesUtils", PlacesUtils)
console.debug("DATA END   .......................................................")

PlacesUtils.observers.addListener(["page-visited"], listener);
