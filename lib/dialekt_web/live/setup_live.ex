defmodule DialektWeb.SetupLive do
  use DialektWeb, :live_view

  alias Dialekt.Languages

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       native_lang: nil,
       target_lang: nil,
       cefr_level: nil,
       register: nil,
       show_native_search: false,
       native_search: "",
       target_search: ""
     )}
  end

  @impl true
  def handle_event("select_native", %{"code" => code}, socket) do
    language = Languages.get_language(code)

    {:noreply,
     assign(socket,
       native_lang: language,
       target_lang: nil,
       show_native_search: false,
       native_search: ""
     )}
  end

  def handle_event("toggle_native_search", _, socket) do
    {:noreply, assign(socket, show_native_search: !socket.assigns.show_native_search)}
  end

  def handle_event("update_native_search", %{"search" => search}, socket) do
    {:noreply, assign(socket, native_search: search)}
  end

  def handle_event("update_target_search", %{"search" => search}, socket) do
    {:noreply, assign(socket, target_search: search)}
  end

  def handle_event("select_target", %{"code" => code}, socket) do
    language = Languages.get_language(code)
    {:noreply, assign(socket, target_lang: language)}
  end

  def handle_event("select_level", %{"code" => code}, socket) do
    level = Languages.get_cefr_level(code)
    {:noreply, assign(socket, cefr_level: level)}
  end

  def handle_event("select_register", %{"code" => code}, socket) do
    register = Languages.get_register(code)
    {:noreply, assign(socket, register: register)}
  end

  def handle_event("start", _, socket) do
    %{
      native_lang: native,
      target_lang: target,
      cefr_level: level,
      register: register
    } = socket.assigns

    if native && target && level && register do
      {:noreply,
       push_navigate(socket,
         to:
           ~p"/chat?native=#{native.code}&target=#{target.code}&level=#{level.code}&register=#{register.code}"
       )}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:select_target, code}, socket) do
    language = Languages.get_language(code)
    {:noreply, assign(socket, target_lang: language)}
  end

  def handle_info({:select_level, code}, socket) do
    level = Languages.get_cefr_level(code)
    {:noreply, assign(socket, cefr_level: level)}
  end

  def handle_info({:select_register, code}, socket) do
    register = Languages.get_register(code)
    {:noreply, assign(socket, register: register)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50 flex items-start justify-center px-4 py-8">
      <div class="w-full max-width bg-white rounded-lg shadow-lg p-8">
        <div class="text-center mb-8">
          <h1 class="text-4xl font-mono font-bold mb-4">DIALEKT</h1>
          <p class="text-gray-600 italic">
            "So the Lord scattered them over the face of the whole earth." — Genesis 11:8
          </p>
        </div>

        <div class="space-y-6">
          <!-- Step 1: Native Language -->
          <section>
            <div class="flex items-baseline gap-2 mb-4">
              <span class="text-xs font-semibold text-gray-500">01</span>
              <span class="text-lg italic">I speak</span>
            </div>

            <div class="flex flex-wrap gap-2 mb-4">
              <%= for lang <- Languages.native_quick_languages() do %>
                <button
                  phx-click="select_native"
                  phx-value-code={lang.code}
                  class={[
                    "px-4 py-2 rounded-full border transition-colors",
                    @native_lang && @native_lang.code == lang.code &&
                      "bg-gray-800 text-white border-gray-800"
                  ]}
                >
                  {lang.flag} {lang.name}
                </button>
              <% end %>
              <button
                phx-click="toggle_native_search"
                class="px-4 py-2 rounded-full border border-dashed"
              >
                {if @show_native_search, do: "↑ less", else: "⊕ other"}
              </button>
            </div>

            <%= if @show_native_search do %>
              <div class="mt-4">
                <input
                  type="text"
                  phx-change="update_native_search"
                  value={@native_search}
                  name="search"
                  placeholder="Search your language..."
                  class="w-full px-4 py-2 border rounded-lg"
                />
                <div class="mt-2 max-h-48 overflow-y-auto border rounded-lg">
                  <%= for lang <- filter_languages(Languages.all_languages(), @native_search) do %>
                    <button
                      phx-click="select_native"
                      phx-value-code={lang.code}
                      class={[
                        "w-full text-left px-4 py-2 hover:bg-gray-50 flex items-center gap-2",
                        @native_lang && @native_lang.code == lang.code && "bg-gray-100"
                      ]}
                    >
                      <span>{lang.flag}</span>
                      <span class="font-medium">{lang.name}</span>
                      <span class="text-gray-500 text-sm">{lang.native}</span>
                    </button>
                  <% end %>
                </div>
              </div>
            <% end %>
          </section>

          <hr />
          
    <!-- Step 2: Target Language -->
          <section class={[@native_lang == nil && "opacity-25 pointer-events-none"]}>
            <div class="flex items-baseline gap-2 mb-4">
              <span class="text-xs font-semibold text-gray-500">02</span>
              <span class="text-lg italic">I want to learn</span>
            </div>

            <%= if @native_lang do %>
              <div phx-value-step="target">
                <input
                  type="text"
                  phx-change="update_target_search"
                  value={@target_search}
                  name="search"
                  placeholder="Search a language to learn..."
                  class="w-full px-4 py-2 border rounded-lg"
                />
                <div class="mt-2 max-h-48 overflow-y-auto border rounded-lg">
                  <%= for lang <- filter_target_languages(@native_lang, Languages.all_languages(), @target_search) do %>
                    <button
                      phx-click="select_target"
                      phx-value-code={lang.code}
                      class={[
                        "w-full text-left px-4 py-2 hover:bg-gray-50 flex items-center gap-2",
                        @target_lang && @target_lang.code == lang.code && "bg-gray-100"
                      ]}
                    >
                      <span>{lang.flag}</span>
                      <span class="font-medium">{lang.name}</span>
                      <span class="text-gray-500 text-sm">{lang.native}</span>
                    </button>
                  <% end %>
                </div>
              </div>
            <% else %>
              <p class="text-gray-500">Select your native language first</p>
            <% end %>
          </section>

          <hr />
          
    <!-- Step 3: CEFR Level -->
          <section class={[@target_lang == nil && "opacity-25 pointer-events-none"]}>
            <div class="flex items-baseline gap-2 mb-4">
              <span class="text-xs font-semibold text-gray-500">03</span>
              <span class="text-lg italic">My level</span>
            </div>

            <%= if @target_lang do %>
              <div class="grid grid-cols-6 gap-2">
                <%= for level <- Languages.cefr_levels() do %>
                  <button
                    phx-click="select_level"
                    phx-value-code={level.code}
                    class={[
                      "flex flex-col items-center py-3 px-2 border rounded-lg transition-colors",
                      @cefr_level && @cefr_level.code == level.code &&
                        "bg-gray-800 text-white border-gray-800"
                    ]}
                  >
                    <span class="font-bold">{level.label}</span>
                    <span class="text-xs">{level.desc}</span>
                  </button>
                <% end %>
              </div>
            <% else %>
              <p class="text-gray-500">Select a language to learn first</p>
            <% end %>
          </section>

          <hr />
          
    <!-- Step 4: Register -->
          <section class={[@cefr_level == nil && "opacity-25 pointer-events-none"]}>
            <div class="flex items-baseline gap-2 mb-4">
              <span class="text-xs font-semibold text-gray-500">04</span>
              <span class="text-lg italic">Register</span>
            </div>

            <%= if @cefr_level do %>
              <div class="grid grid-cols-2 gap-4">
                <%= for register <- Languages.registers() do %>
                  <button
                    phx-click="select_register"
                    phx-value-code={register.code}
                    class={[
                      "flex flex-col items-center py-4 px-4 border rounded-lg transition-colors",
                      @register && @register.code == register.code &&
                        "bg-gray-800 text-white border-gray-800"
                    ]}
                  >
                    <span class="text-2xl mb-2">{register.icon}</span>
                    <span class="font-semibold">{register.label}</span>
                    <span class="text-xs text-center">{register.desc}</span>
                  </button>
                <% end %>
              </div>
            <% else %>
              <p class="text-gray-500">Select your level first</p>
            <% end %>
          </section>
        </div>
        
    <!-- Start Button -->
        <button
          phx-click="start"
          disabled={!(@native_lang && @target_lang && @cefr_level && @register)}
          class={[
            "w-full mt-8 py-3 px-4 rounded-lg font-medium transition-all",
            @native_lang && @target_lang && @cefr_level && @register &&
              "bg-gray-800 text-white hover:bg-gray-700",
            !(@native_lang && @target_lang && @cefr_level && @register) &&
              "bg-gray-200 text-gray-500 cursor-not-allowed"
          ]}
        >
          <%= if @native_lang && @target_lang && @cefr_level && @register do %>
            Start {@register.label} {@target_lang.name} at {@cefr_level.code} {@target_lang.flag}
            <span class="ml-auto">→</span>
          <% else %>
            Complete all steps above
          <% end %>
        </button>
      </div>
    </div>

    <style>
      .max-width {
        max-width: 520px;
      }
    </style>
    """
  end

  defp filter_languages(languages, search) do
    search_term = String.downcase(search)

    if search_term == "" do
      languages
    else
      Enum.filter(languages, fn lang ->
        String.contains?(String.downcase(lang.name), search_term) ||
          String.contains?(String.downcase(lang.native), search_term)
      end)
    end
  end

  defp filter_target_languages(native, languages, search) do
    languages
    |> Enum.filter(&(&1.code != native.code))
    |> filter_languages(search)
  end
end
