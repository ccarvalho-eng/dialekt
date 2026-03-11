// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//
// If you have dependencies that try to import CSS, esbuild will generate a separate `app.css` file.
// To load it, simply add a second `<link>` to your `root.html.heex` file.

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import {hooks as colocatedHooks} from "phoenix-colocated/dialekt"
import topbar from "../vendor/topbar"

const Hooks = {}

Hooks.ChatInput = {
  mounted() {
    this.el.addEventListener("keydown", (e) => {
      if (e.key === "Enter" && !e.shiftKey) {
        e.preventDefault()
        const value = this.el.value.trim()
        if (value !== "") {
          this.pushEvent("send_message", {})
          this.el.value = ""
        }
      }
    })
  }
}

Hooks.ChatScroll = {
  mounted() {
    this.scrollToBottom()
  },

  updated() {
    this.scrollToBottom()
  },

  scrollToBottom() {
    this.el.scrollTop = this.el.scrollHeight
  }
}

Hooks.ConfigNameInput = {
  mounted() {
    this.el.addEventListener("keydown", (e) => {
      const configId = this.el.dataset.configId

      if (e.key === "Enter") {
        e.preventDefault()
        const value = this.el.value.trim()
        this.pushEvent("save_name_with_value", {
          "config-id": configId,
          name: value
        })
      } else if (e.key === "Escape") {
        e.preventDefault()
        this.pushEvent("cancel_edit", {})
      }
    })
  }
}

Hooks.ThemeManager = {
  mounted() {
    const savedTheme = localStorage.getItem("dialekt-theme") || "light"
    document.documentElement.setAttribute("data-theme", savedTheme)

    // Sync saved theme to LiveView
    this.pushEvent("sync_theme", {theme: savedTheme})

    // Listen for theme changes from server
    this.handleEvent("update-theme", ({theme}) => {
      document.documentElement.setAttribute("data-theme", theme)
      localStorage.setItem("dialekt-theme", theme)
    })
  },

  updated() {
    const theme = this.el.dataset.theme
    if (theme) {
      document.documentElement.setAttribute("data-theme", theme)
      localStorage.setItem("dialekt-theme", theme)
    }
  }
}

Hooks.SidebarState = {
  mounted() {
    // Read initial state from localStorage
    const collapsed = localStorage.getItem("dialekt-sidebar-collapsed") === "true"

    // Send initial state to server
    this.pushEvent("init_sidebar_state", { collapsed })

    // Listen for state changes from server and persist
    this.handleEvent("sidebar_state_changed", ({ collapsed }) => {
      localStorage.setItem("dialekt-sidebar-collapsed", collapsed)
    })
  }
}

Hooks.TextToSpeech = {
  mounted() {
    // Check if speech synthesis is supported
    if (!window.speechSynthesis) {
      this.el.style.display = 'none'
      return
    }

    // Complete language to locale mapping (70 languages)
    // Matches flag country codes from dialekt/languages.ex
    const langToLocale = {
      // Verified languages (15) - known good Web Speech API support
      'en': 'en-GB',
      'es': 'es-ES',
      'fr': 'fr-FR',
      'de': 'de-DE',
      'it': 'it-IT',
      'pt': 'pt-BR',
      'ja': 'ja-JP',
      'ko': 'ko-KR',
      'zh': 'zh-CN',
      'ru': 'ru-RU',
      'ar': 'ar-SA',
      'hi': 'hi-IN',
      'nl': 'nl-NL',
      'pl': 'pl-PL',
      'sv': 'sv-SE',

      // Additional languages (55+)
      'af': 'af-ZA',   // Afrikaans - South Africa
      'sq': 'sq-AL',   // Albanian - Albania
      'hy': 'hy-AM',   // Armenian - Armenia
      'az': 'az-AZ',   // Azerbaijani - Azerbaijan
      'bn': 'bn-BD',   // Bengali - Bangladesh
      'bs': 'bs-BA',   // Bosnian - Bosnia
      'bg': 'bg-BG',   // Bulgarian - Bulgaria
      'ca': 'ca-ES',   // Catalan - Spain
      'hr': 'hr-HR',   // Croatian - Croatia
      'cs': 'cs-CZ',   // Czech - Czech Republic
      'da': 'da-DK',   // Danish - Denmark
      'et': 'et-EE',   // Estonian - Estonia
      'fi': 'fi-FI',   // Finnish - Finland
      'ka': 'ka-GE',   // Georgian - Georgia
      'el': 'el-GR',   // Greek - Greece
      'gu': 'gu-IN',   // Gujarati - India
      'ht': 'ht-HT',   // Haitian Creole - Haiti
      'he': 'he-IL',   // Hebrew - Israel
      'hu': 'hu-HU',   // Hungarian - Hungary
      'is': 'is-IS',   // Icelandic - Iceland
      'id': 'id-ID',   // Indonesian - Indonesia
      'ga': 'ga-IE',   // Irish - Ireland
      'kn': 'kn-IN',   // Kannada - India
      'kk': 'kk-KZ',   // Kazakh - Kazakhstan
      'km': 'km-KH',   // Khmer - Cambodia
      'lv': 'lv-LV',   // Latvian - Latvia
      'lt': 'lt-LT',   // Lithuanian - Lithuania
      'mk': 'mk-MK',   // Macedonian - North Macedonia
      'ms': 'ms-MY',   // Malay - Malaysia
      'ml': 'ml-IN',   // Malayalam - India
      'mt': 'mt-MT',   // Maltese - Malta
      'mr': 'mr-IN',   // Marathi - India
      'mn': 'mn-MN',   // Mongolian - Mongolia
      'ne': 'ne-NP',   // Nepali - Nepal
      'nb': 'nb-NO',   // Norwegian - Norway
      'fa': 'fa-IR',   // Persian - Iran
      'pa': 'pa-IN',   // Punjabi - India
      'ro': 'ro-RO',   // Romanian - Romania
      'sr': 'sr-RS',   // Serbian - Serbia
      'sk': 'sk-SK',   // Slovak - Slovakia
      'sl': 'sl-SI',   // Slovenian - Slovenia
      'so': 'so-SO',   // Somali - Somalia
      'sw': 'sw-KE',   // Swahili - Kenya
      'tl': 'tl-PH',   // Tagalog - Philippines
      'ta': 'ta-IN',   // Tamil - India
      'te': 'te-IN',   // Telugu - India
      'th': 'th-TH',   // Thai - Thailand
      'tr': 'tr-TR',   // Turkish - Turkey
      'uk': 'uk-UA',   // Ukrainian - Ukraine
      'ur': 'ur-PK',   // Urdu - Pakistan
      'uz': 'uz-UZ',   // Uzbek - Uzbekistan
      'vi': 'vi-VN',   // Vietnamese - Vietnam
      'cy': 'cy-GB',   // Welsh - Wales (uses GB)
      'zu': 'zu-ZA'    // Zulu - South Africa
    }

    // Languages with verified good Web Speech API support
    const verifiedLanguages = new Set([
      'en', 'es', 'fr', 'de', 'it', 'pt', 'ja', 'ko', 'zh',
      'ru', 'ar', 'hi', 'nl', 'pl', 'sv'
    ])

    // Check if this language is verified and set data attribute
    const langCode = this.el.dataset.lang
    const isVerified = verifiedLanguages.has(langCode)

    // Set verification status for CSS styling
    if (isVerified) {
      this.el.dataset.verified = 'true'
      this.el.title = 'Listen'
    } else {
      this.el.dataset.verified = 'false'
      this.el.title = 'Listen (quality may vary)'
    }

    this.handleClick = () => {
      const text = this.el.dataset.text
      const langCode = this.el.dataset.lang

      if (!text || !langCode) return

      // Stop any ongoing speech
      window.speechSynthesis.cancel()

      // Create utterance with mapped language
      const utterance = new SpeechSynthesisUtterance(text)
      utterance.lang = langToLocale[langCode] || langCode

      // Optional: Add visual feedback
      this.el.style.opacity = '0.6'
      utterance.onend = () => {
        this.el.style.opacity = '1'
      }

      utterance.onerror = (event) => {
        console.error('TTS error:', event)
        this.el.style.opacity = '1'
      }

      // Speak the text
      window.speechSynthesis.speak(utterance)
    }

    this.el.addEventListener('click', this.handleClick)
  },

  destroyed() {
    // Cancel any ongoing speech when element is removed
    window.speechSynthesis.cancel()
    if (this.handleClick) {
      this.el.removeEventListener('click', this.handleClick)
    }
  }
}

const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
const liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: () => {
    const theme = localStorage.getItem("dialekt-theme") || "light"
    const sidebarCollapsed = localStorage.getItem("dialekt-sidebar-collapsed") === "true"
    return {_csrf_token: csrfToken, theme: theme, sidebar_collapsed: sidebarCollapsed}
  },
  hooks: {...colocatedHooks, ...Hooks},
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

// The lines below enable quality of life phoenix_live_reload
// development features:
//
//     1. stream server logs to the browser console
//     2. click on elements to jump to their definitions in your code editor
//
if (process.env.NODE_ENV === "development") {
  window.addEventListener("phx:live_reload:attached", ({detail: reloader}) => {
    // Enable server log streaming to client.
    // Disable with reloader.disableServerLogs()
    reloader.enableServerLogs()

    // Open configured PLUG_EDITOR at file:line of the clicked element's HEEx component
    //
    //   * click with "c" key pressed to open at caller location
    //   * click with "d" key pressed to open at function component definition location
    let keyDown
    window.addEventListener("keydown", e => keyDown = e.key)
    window.addEventListener("keyup", e => keyDown = null)
    window.addEventListener("click", e => {
      if(keyDown === "c"){
        e.preventDefault()
        e.stopImmediatePropagation()
        reloader.openEditorAtCaller(e.target)
      } else if(keyDown === "d"){
        e.preventDefault()
        e.stopImmediatePropagation()
        reloader.openEditorAtDef(e.target)
      }
    }, true)

    window.liveReloader = reloader
  })
}

