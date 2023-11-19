import {Injector} from "chrome://userchrome/content/js/utils.mjs"

// console.debug('Loading userscripts')

// only load predefined userscripts in the correct directory
const chrome_prefix = "chrome://userchrome/content/js/"
const scripts = [
    // add scripts from the js subdirectory to this array
    "sidebery_search_tag.uc.js",
    "pdfjs_autotheme.uc.js",
].map(script => chrome_prefix + script)

const injector = new Injector(scripts)
// console.debug('Successfully created userscript injector')
