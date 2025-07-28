// Stolen from MrOtherGuy: https://github.com/MrOtherGuy/fx-autoconfig/
// Check the (scarce) README for details.

const {AppConstants} = ChromeUtils.importESModule("resource://gre/modules/AppConstants.sys.mjs")

const APP_NAME = AppConstants.MOZ_APP_DISPLAYNAME_DO_NOT_USE


/**
 * Inject scripts into new windows.
 */
export class Injector {
    /**
     * Construct a new Injector.
     *
     * @param {string[]} scripts An array of chrome URIs of scripts.
     * @param {boolean} cache Whether to use the cache or not.     */
    constructor(scripts, cache = false) {
        console.debug("Creating Injector")
        this.scripts = scripts
        this.cache = cache
        this.#init()
        console.debug("Created Injector")
    }

    /**
     * Make sure to inject userscripts into new windows, on load.
     */
    #init() {
        if (!Services.appinfo.inSafeMode) {
            console.debug("Attaching observer for domwindowopened event")
            Services.obs.addObserver(this, 'domwindowopened', false)
        } else {
            console.debug(`${APP_NAME} was started in safe mode, not attaching userscripts`)
        }
    }

    /**
     * Callback for the `DOMContentLoaded` event.
     *
     * @param {Document} document The document that was loaded.
     */
    #onDOMContentLoaded(document) {
        console.debug("DOMContentLoaded received", document)
        const window = document.defaultView
        const window_uri = window.location.href

        // Don't inject scripts to modal prompt windows or notifications
        const ignore_regex = /^chrome:(?!\/\/global\/content\/(commonDialog|alerts\/alert)\.xhtml)|about:(?!blank)/i
        if (!ignore_regex.test(window_uri)) {
            console.debug(`Ignoring page ${window_uri} for script injection`)
            return
        }

        for (const script of this.scripts) this.#injectClassicScript(script, window)
    }

    /**
     * Inject a script into a window.
     *
     * @param script Chrome URI of the script to inject into a window.
     * @param window The window to inject the script into.
     * @returns {Promise<Awaited<number>>} IDK why, I'm just mindlessly copying that part.
     */
    #injectClassicScript(script, window) {
        const window_uri = window.location.href
        try {
            console.debug(`Try to inject classic script: ${script} into ${window_uri}`)

            const uri = Services.io.newURI(script)
            Services.scriptloader.loadSubScriptWithOptions(uri.spec, {
                target: window, ignoreCache: !this.cache,
            })

            console.debug(`Successfully injected classic script: ${script} into ${window_uri}`)
            // not sure why we return this promise here, but this is how MrOtherGuy did it, I think
            return Promise.resolve(1)
        } catch (e) {
            console.error(`Failed to inject script ${script} into ${window_uri}:`, e)
        }
    }

    /**
     * Attaches this injector as an event listener.
     * Called by the observable on `domwindowopened`?
     * Registration is done in the `init` method.
     *
     * @param subject
     * @param topic
     * @param data
     */
    observe(subject, topic, data) {
        console.debug("Called observe with parameters:", subject, topic, data)
        subject.addEventListener('DOMContentLoaded', this, true)
    }

    /**
     * Called on `DOMContentLoaded` events after `domwindowopened`.
     * Registration is done in the `observe` method.
     *
     * @param {Event} event The `DOMContentLoaded` event.
     */
    handleEvent(event) {
        console.debug("Event received", event)

        switch (event.type) {
            case "DOMContentLoaded":
                const document = event.originalTarget
                this.#onDOMContentLoaded(document)
                break
            default:
                console.warn(new Error("Unexpected event received", {cause: event}))
        }
    }

    // TODO this code could be useful somewhere else, otherwise remove it
    //
    // const IS_TB = AppConstants.BROWSER_CHROME_URL.startsWith("chrome://messenger")
    // const IS_FF = !IS_TB
    //
    // /**
    //  * @returns {Promise<unknown>} After this, the browser has started.
    //  */
    // static #startupFinished() {
    //     console.debug("Waiting for startup to finish")
    //     let session_restored = false
    //     return new Promise(resolve => {
    //         if (session_restored) {
    //             console.debug("Startup finished")
    //             resolve()
    //         } else {
    //             console.debug("Attaching observer for session restore")
    //             const obs_topic = IS_FF
    //                 ? "sessionstore-windows-restored"
    //                 : "browser-delayed-startup-finished"
    //             let observer = (subject, topic, data) => {
    //                 Services.obs.removeObserver(observer, obs_topic)
    //                 session_restored = true
    //                 resolve()
    //                 console.debug("Session was restored and observer removed itself")
    //             }
    //             Services.obs.addObserver(observer, obs_topic)
    //         }
    //     })
    // }
    //
    // NOTE: use like so
    //
    // console.debug("Awaiting startup")
    // const startup = Promise.resolve(Injector.#startupFinished)
    // startup.then(() => {
    //     console.debug("Doing the thing")
    // }).catch(ex => console.error("Failed to await startup:", ex))

}
