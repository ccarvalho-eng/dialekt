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

// VoiceInput configuration constants
const VOICE_INPUT_CONFIG = {
  LANG_SWITCH_DELAY_MS: 100,
  FFT_SIZE: 256,
  WAVEFORM_BAR_COUNT: 40,
  WAVEFORM_HEIGHT_SCALE: 0.8,
  WAVEFORM_BAR_GAP: 2
}

// Language to locale mapping for speech APIs (70+ languages)
// Shared between TextToSpeech and VoiceInput hooks
const LANG_TO_LOCALE = {
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
      utterance.lang = LANG_TO_LOCALE[langCode] || langCode

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

Hooks.VoiceInput = {
  mounted() {
    this.isRecording = false
    this.recognition = null
    this.audioContext = null
    this.analyser = null
    this.microphone = null
    this.animationId = null

    // Check browser support
    const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition
    if (!SpeechRecognition) {
      this.el.style.display = 'none'
      console.warn('Speech recognition not supported in this browser')
      return
    }

    // Get languages from data attributes
    this.targetLang = this.el.dataset.targetLang
    this.nativeLang = this.el.dataset.nativeLang
    this.currentLang = this.targetLang // Start with target language

    // Get language indicator element
    this.langIndicatorId = this.el.dataset.langIndicatorId
    this.langIndicator = document.getElementById(this.langIndicatorId)

    // Setup language toggle handler
    if (this.langIndicator) {
      this.handleLangToggle = () => this.toggleLanguage()
      this.langIndicator.addEventListener('click', this.handleLangToggle)
    }

    // Store handler reference for cleanup
    this.handleClick = () => this.toggleRecording()
    this.el.addEventListener('click', this.handleClick)
  },

  toggleLanguage() {
    // Switch between target and native language
    this.currentLang = this.currentLang === this.targetLang ? this.nativeLang : this.targetLang
    this.updateLanguageIndicator()

    // If recording, restart recognition with new language
    if (this.isRecording && this.recognition) {
      this.recognition.stop()
      setTimeout(() => {
        if (this.isRecording) {
          this.recognition.lang = this.getLangCode(this.currentLang)
          try {
            this.recognition.start()
          } catch (error) {
            console.error('Failed to restart recognition:', error)
          }
        }
      }, VOICE_INPUT_CONFIG.LANG_SWITCH_DELAY_MS)
    }
  },

  updateLanguageIndicator() {
    if (this.langIndicator) {
      const isTarget = this.currentLang === this.targetLang
      this.langIndicator.textContent = this.currentLang.toUpperCase()
      this.langIndicator.classList.toggle('target-lang', isTarget)
      this.langIndicator.classList.toggle('native-lang', !isTarget)
      this.langIndicator.title = isTarget
        ? `Listening in target language (${this.currentLang}). Click to switch.`
        : `Listening in native language (${this.currentLang}). Click to switch.`
    }
  },

  toggleRecording() {
    if (this.isRecording) {
      this.stopRecording()
    } else {
      this.startRecording()
    }
  },

  getLangCode(code) {
    return LANG_TO_LOCALE[code] || code
  },

  async startRecording() {
    try {
      // Request microphone access
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true })

      // Get textarea reference
      const textareaId = this.el.dataset.textareaId

      // Setup speech recognition - simple mode, no real-time
      const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition
      this.recognition = new SpeechRecognition()
      this.recognition.continuous = false
      this.recognition.interimResults = false
      this.recognition.lang = this.getLangCode(this.currentLang)
      this.recognition.maxAlternatives = 1

      // Handle final results only
      this.recognition.onresult = (event) => {
        const transcript = event.results[0][0].transcript

        // Update textarea value directly
        const textarea = document.getElementById(textareaId)
        if (textarea) {
          textarea.value = transcript

          // Dispatch as if user typed
          const inputEvent = new Event('input', { bubbles: true })
          Object.defineProperty(inputEvent, 'target', {
            writable: false,
            value: { value: transcript }
          })
          textarea.dispatchEvent(inputEvent)
        }
      }

      this.recognition.onerror = async (event) => {
        console.error('Speech recognition error:', event.error)

        if (event.error === 'no-speech') {
          // No speech detected - this is normal, keep recording
          return
        } else if (event.error === 'aborted') {
          // User stopped recording, don't show error
          return
        } else if (event.error === 'not-allowed') {
          alert('Microphone access denied')
          await this.stopRecording()
        } else if (event.error === 'network') {
          alert('Network error - speech recognition unavailable')
          await this.stopRecording()
        } else {
          // Other errors - stop recording
          console.error('Recognition error:', event.error)
          await this.stopRecording()
        }
      }

      this.recognition.onend = () => {
        // Recognition ended but keep waveform visible
        // Don't stop recording - let user decide when to stop
      }

      // Setup audio visualization
      this.audioContext = new (window.AudioContext || window.webkitAudioContext)()
      this.analyser = this.audioContext.createAnalyser()
      this.analyser.fftSize = VOICE_INPUT_CONFIG.FFT_SIZE
      this.microphone = this.audioContext.createMediaStreamSource(stream)
      this.microphone.connect(this.analyser)

      // Set recording state BEFORE drawing waveform
      this.isRecording = true
      this.stream = stream

      // Get canvas element and cache color
      const canvasId = this.el.dataset.canvasId
      this.canvas = document.getElementById(canvasId)
      if (this.canvas) {
        this.canvasContext = this.canvas.getContext('2d')
        this.cachedColor = getComputedStyle(document.documentElement).getPropertyValue('--color-base-content').trim() || 'oklch(21% 0.006 285.885)'
        this.drawWaveform()
      }

      // Start recognition (can throw)
      try {
        this.recognition.start()
      } catch (error) {
        console.error('Failed to start speech recognition:', error)
        this.isRecording = false
        await this.cleanup()
        throw error
      }

      // Update UI
      this.el.classList.add('recording')
      if (this.canvas) {
        this.canvas.style.display = 'block'
      }

      // Show recording status and language indicator
      const statusId = this.el.dataset.statusId
      const status = document.getElementById(statusId)
      if (status) {
        status.style.display = 'flex'
      }

      // Update and show language indicator
      this.updateLanguageIndicator()
    } catch (error) {
      console.error('Failed to start recording:', error)

      let message = 'Could not start voice input. '
      if (error.name === 'NotAllowedError') {
        message += 'Microphone access denied. Please allow microphone access and try again.'
      } else if (error.name === 'NotFoundError') {
        message += 'No microphone found.'
      } else {
        message += error.message
      }

      alert(message)
      await this.cleanup()
    }
  },

  async stopRecording() {
    if (this.recognition) {
      this.recognition.stop()
      this.recognition = null
    }

    await this.cleanup()

    this.isRecording = false
    this.el.classList.remove('recording')

    if (this.canvas) {
      this.canvas.style.display = 'none'
    }

    // Hide recording status
    const statusId = this.el.dataset.statusId
    const status = document.getElementById(statusId)
    if (status) {
      status.style.display = 'none'
    }
  },

  async cleanup() {
    if (this.animationId) {
      cancelAnimationFrame(this.animationId)
      this.animationId = null
    }

    if (this.stream) {
      this.stream.getTracks().forEach(track => track.stop())
      this.stream = null
    }

    if (this.microphone) {
      this.microphone.disconnect()
      this.microphone = null
    }

    if (this.audioContext) {
      await this.audioContext.close()
      this.audioContext = null
    }

    this.analyser = null
  },

  drawWaveform() {
    if (!this.isRecording || !this.canvas) {
      return
    }

    const bufferLength = this.analyser.frequencyBinCount
    const dataArray = new Uint8Array(bufferLength)
    this.analyser.getByteFrequencyData(dataArray)

    const canvas = this.canvas
    const canvasCtx = this.canvasContext
    const width = canvas.width
    const height = canvas.height

    // Clear canvas
    canvasCtx.clearRect(0, 0, width, height)

    // Draw bars
    const barCount = VOICE_INPUT_CONFIG.WAVEFORM_BAR_COUNT
    const barWidth = width / barCount
    const step = Math.floor(bufferLength / barCount)

    for (let i = 0; i < barCount; i++) {
      const value = dataArray[i * step]
      const barHeight = (value / 255) * height * VOICE_INPUT_CONFIG.WAVEFORM_HEIGHT_SCALE
      const x = i * barWidth
      const y = (height - barHeight) / 2

      // Use cached color
      canvasCtx.fillStyle = this.cachedColor
      canvasCtx.fillRect(x, y, barWidth - VOICE_INPUT_CONFIG.WAVEFORM_BAR_GAP, barHeight)
    }

    this.animationId = requestAnimationFrame(() => this.drawWaveform())
  },

  destroyed() {
    if (this.handleClick) {
      this.el.removeEventListener('click', this.handleClick)
    }
    if (this.handleLangToggle && this.langIndicator) {
      this.langIndicator.removeEventListener('click', this.handleLangToggle)
    }
    this.cleanup()
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

