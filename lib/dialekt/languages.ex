defmodule Dialekt.Languages do
  @moduledoc """
  Provides language data, CEFR levels, and registers for the Dialekt app.
  """

  @all_languages [
    %{code: "af", name: "Afrikaans", flag: "🇿🇦", native: "Afrikaans"},
    %{code: "sq", name: "Albanian", flag: "🇦🇱", native: "Shqip"},
    %{code: "ar", name: "Arabic", flag: "🇸🇦", native: "العربية"},
    %{code: "hy", name: "Armenian", flag: "🇦🇲", native: "Հայերեն"},
    %{code: "az", name: "Azerbaijani", flag: "🇦🇿", native: "Azərbaycanca"},
    %{code: "bn", name: "Bengali", flag: "🇧🇩", native: "বাংলা"},
    %{code: "bs", name: "Bosnian", flag: "🇧🇦", native: "Bosanski"},
    %{code: "bg", name: "Bulgarian", flag: "🇧🇬", native: "Български"},
    %{code: "ca", name: "Catalan", flag: "🏴", native: "Català"},
    %{code: "zh", name: "Mandarin", flag: "🇨🇳", native: "普通话"},
    %{code: "hr", name: "Croatian", flag: "🇭🇷", native: "Hrvatski"},
    %{code: "cs", name: "Czech", flag: "🇨🇿", native: "Čeština"},
    %{code: "da", name: "Danish", flag: "🇩🇰", native: "Dansk"},
    %{code: "nl", name: "Dutch", flag: "🇳🇱", native: "Nederlands"},
    %{code: "en", name: "English", flag: "🇬🇧", native: "English"},
    %{code: "et", name: "Estonian", flag: "🇪🇪", native: "Eesti"},
    %{code: "fi", name: "Finnish", flag: "🇫🇮", native: "Suomi"},
    %{code: "fr", name: "French", flag: "🇫🇷", native: "Français"},
    %{code: "ka", name: "Georgian", flag: "🇬🇪", native: "ქართული"},
    %{code: "de", name: "German", flag: "🇩🇪", native: "Deutsch"},
    %{code: "el", name: "Greek", flag: "🇬🇷", native: "Ελληνικά"},
    %{code: "gu", name: "Gujarati", flag: "🇮🇳", native: "ગુજરાતી"},
    %{code: "ht", name: "Haitian Creole", flag: "🇭🇹", native: "Kreyol"},
    %{code: "he", name: "Hebrew", flag: "🇮🇱", native: "עברית"},
    %{code: "hi", name: "Hindi", flag: "🇮🇳", native: "हिन्दी"},
    %{code: "hu", name: "Hungarian", flag: "🇭🇺", native: "Magyar"},
    %{code: "is", name: "Icelandic", flag: "🇮🇸", native: "Islenska"},
    %{code: "id", name: "Indonesian", flag: "🇮🇩", native: "Bahasa Indonesia"},
    %{code: "ga", name: "Irish", flag: "🇮🇪", native: "Gaeilge"},
    %{code: "it", name: "Italian", flag: "🇮🇹", native: "Italiano"},
    %{code: "ja", name: "Japanese", flag: "🇯🇵", native: "日本語"},
    %{code: "kn", name: "Kannada", flag: "🇮🇳", native: "ಕನ್ನಡ"},
    %{code: "kk", name: "Kazakh", flag: "🇰🇿", native: "Qazaqsha"},
    %{code: "km", name: "Khmer", flag: "🇰🇭", native: "ខ្មែរ"},
    %{code: "ko", name: "Korean", flag: "🇰🇷", native: "한국어"},
    %{code: "lv", name: "Latvian", flag: "🇱🇻", native: "Latviesu"},
    %{code: "lt", name: "Lithuanian", flag: "🇱🇹", native: "Lietuviu"},
    %{code: "mk", name: "Macedonian", flag: "🇲🇰", native: "Makedonski"},
    %{code: "ms", name: "Malay", flag: "🇲🇾", native: "Bahasa Melayu"},
    %{code: "ml", name: "Malayalam", flag: "🇮🇳", native: "മലയാളം"},
    %{code: "mt", name: "Maltese", flag: "🇲🇹", native: "Malti"},
    %{code: "mr", name: "Marathi", flag: "🇮🇳", native: "मराठी"},
    %{code: "mn", name: "Mongolian", flag: "🇲🇳", native: "Mongol"},
    %{code: "ne", name: "Nepali", flag: "🇳🇵", native: "नेपाली"},
    %{code: "nb", name: "Norwegian", flag: "🇳🇴", native: "Norsk"},
    %{code: "fa", name: "Persian", flag: "🇮🇷", native: "فارسی"},
    %{code: "pl", name: "Polish", flag: "🇵🇱", native: "Polski"},
    %{code: "pt", name: "Portuguese", flag: "🇧🇷", native: "Português"},
    %{code: "pa", name: "Punjabi", flag: "🇮🇳", native: "ਪੰਜਾਬੀ"},
    %{code: "ro", name: "Romanian", flag: "🇷🇴", native: "Română"},
    %{code: "ru", name: "Russian", flag: "🇷🇺", native: "Russkiy"},
    %{code: "sr", name: "Serbian", flag: "🇷🇸", native: "Srpski"},
    %{code: "sk", name: "Slovak", flag: "🇸🇰", native: "Slovenčina"},
    %{code: "sl", name: "Slovenian", flag: "🇸🇮", native: "Slovenscina"},
    %{code: "so", name: "Somali", flag: "🇸🇴", native: "Soomaali"},
    %{code: "es", name: "Spanish", flag: "🇪🇸", native: "Español"},
    %{code: "sw", name: "Swahili", flag: "🇰🇪", native: "Kiswahili"},
    %{code: "sv", name: "Swedish", flag: "🇸🇪", native: "Svenska"},
    %{code: "tl", name: "Tagalog", flag: "🇵🇭", native: "Tagalog"},
    %{code: "ta", name: "Tamil", flag: "🇮🇳", native: "தமிழ்"},
    %{code: "te", name: "Telugu", flag: "🇮🇳", native: "తెలుగు"},
    %{code: "th", name: "Thai", flag: "🇹🇭", native: "ภาษาไทย"},
    %{code: "tr", name: "Turkish", flag: "🇹🇷", native: "Türkçe"},
    %{code: "uk", name: "Ukrainian", flag: "🇺🇦", native: "Ukrainska"},
    %{code: "ur", name: "Urdu", flag: "🇵🇰", native: "اردو"},
    %{code: "uz", name: "Uzbek", flag: "🇺🇿", native: "Ozbek"},
    %{code: "vi", name: "Vietnamese", flag: "🇻🇳", native: "Tieng Viet"},
    %{code: "cy", name: "Welsh", flag: "🏴", native: "Cymraeg"},
    %{code: "zu", name: "Zulu", flag: "🇿🇦", native: "IsiZulu"}
  ]

  @cefr_levels [
    %{code: "A1", label: "A1", desc: "Beginner"},
    %{code: "A2", label: "A2", desc: "Elementary"},
    %{code: "B1", label: "B1", desc: "Intermediate"},
    %{code: "B2", label: "B2", desc: "Upper Intermediate"},
    %{code: "C1", label: "C1", desc: "Advanced"},
    %{code: "C2", label: "C2", desc: "Mastery"}
  ]

  @registers [
    %{
      code: "informal",
      label: "Informal",
      desc: "Friends, family, casual settings",
      icon: "☕"
    },
    %{
      code: "formal",
      label: "Formal",
      desc: "Work, strangers, official contexts",
      icon: "🤝"
    }
  ]

  @native_quick_codes ["en", "es", "fr", "de", "zh", "ja", "pt", "ar", "ru", "hi", "ko", "it"]

  @doc """
  Returns a list of all available languages.
  """
  def all_languages, do: @all_languages

  @doc """
  Returns a language by its code.
  """
  def get_language(code) do
    Enum.find(@all_languages, fn lang -> lang.code == code end)
  end

  @doc """
  Returns all CEFR levels.
  """
  def cefr_levels, do: @cefr_levels

  @doc """
  Returns a CEFR level by its code.
  """
  def get_cefr_level(code) do
    Enum.find(@cefr_levels, fn level -> level.code == code end)
  end

  @doc """
  Returns available registers (formal and informal).
  """
  def registers, do: @registers

  @doc """
  Returns a register by its code.
  """
  def get_register(code) do
    Enum.find(@registers, fn register -> register.code == code end)
  end

  @doc """
  Returns a quick selection of major native languages.
  """
  def native_quick_languages do
    @native_quick_codes
    |> Enum.map(&get_language/1)
    |> Enum.filter(& &1)
  end
end
