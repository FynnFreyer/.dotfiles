// IMPORTANT: skip the first line

try {
    let cmanifest = Cc['@mozilla.org/file/directory_service;1'].getService(Ci.nsIProperties).get('UChrm', Ci.nsIFile);
    cmanifest.append('chrome.manifest');

    if (cmanifest.exists()) {
        Components.manager.QueryInterface(Ci.nsIComponentRegistrar).autoRegister(cmanifest);
        ChromeUtils.importESModule('chrome://userchrome/content/loader.mjs');
    }
} catch (ex) {}
