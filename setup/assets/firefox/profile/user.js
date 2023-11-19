// set user defaults and other shenanigans
// for additional info see https://github.com/arkenfox/user.js/wiki/2.1-User.js

// styling
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);  // enable userChrome.css
user_pref("svg.context-properties.content.enabled", true);  // apply theme color to sidebery buttons

// additional privacy settings
user_pref("privacy.fingerprintingProtection", true);
user_pref("privacy.resistFingerprinting", true);

// tabbing behaviour
user_pref("browser.ctrlTab.sortByRecentlyUsed", true);

// optionally check whether scripts should be active
// check needs to be implemented in the loader
// user_pref("userChromeJS.enabled", true);
// user_pref("userChromeJS.scriptsDisabled", "");

// enable browser debugging
user_pref("devtools.chrome.enabled", true);
user_pref("devtools.debugger.remote-enabled", true);
user_pref("devtools.debugger.remote-host", "localhost");
user_pref("devtools.debugger.prompt-connection", false);

// fixes dragging issue on GNOME
// Cf. https://www.reddit.com/r/FirefoxCSS/comments/12h5q6j/cant_rearrange_tabs_with_tree_style_tab_full/
// and https://bugzilla.mozilla.org/show_bug.cgi?id=1818517
user_pref("widget.gtk.ignore-bogus-leave-notify", 1);  // TODO remove once bug is fixed

// allow http on localhost
user_pref("browser.fixup.fallback-to-https", false);
user_pref("browser.fixup.alternate.protocol", "http");

/**
 * Lots of stuff could be taken from Betterfox esr115.1
 * See https://github.com/yokoffing/Betterfox
 */
