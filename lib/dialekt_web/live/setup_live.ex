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
    <div class="setup">
      <div class="panel">
        <div class="brand">
          <pre class="brand-ascii">██████  ██  █████  ██      ███████ ██   ██ ████████
    ██   ██ ██ ██   ██ ██      ██      ██  ██     ██
    ██   ██ ██ ███████ ██      █████   █████      ██
    ██   ██ ██ ██   ██ ██      ██      ██  ██     ██
    ██████  ██ ██   ██ ███████ ███████ ██   ██    ██</pre>
        </div>
        <p class="brand-tagline">
          "So the Lord scattered them over the face of the whole earth." — Genesis 11:8
        </p>

        <div class="steps">
          <!-- Step 1: Native Language -->
          <section class="step">
            <div class="step-hd">
              <span class="step-n">01</span>
              <span class="step-label">I speak</span>
            </div>

            <div class="quick-pills">
              <%= for lang <- Languages.native_quick_languages() do %>
                <button
                  phx-click="select_native"
                  phx-value-code={lang.code}
                  class={[
                    "qpill",
                    @native_lang && @native_lang.code == lang.code && "qpill-on"
                  ]}
                >
                  {lang.flag} {lang.name}
                </button>
              <% end %>
              <button
                phx-click="toggle_native_search"
                class="qpill qpill-other"
              >
                {if @show_native_search, do: "↑ less", else: "⊕ other"}
              </button>
            </div>

            <%= if @show_native_search do %>
              <div class="ls-wrap">
                <input
                  type="text"
                  phx-change="update_native_search"
                  value={@native_search}
                  name="search"
                  placeholder="Search your language..."
                  class="ls-input"
                />
                <div class="ls-list">
                  <%= for lang <- filter_languages(Languages.all_languages(), @native_search) do %>
                    <button
                      phx-click="select_native"
                      phx-value-code={lang.code}
                      class={[
                        "ls-row",
                        @native_lang && @native_lang.code == lang.code && "ls-sel"
                      ]}
                    >
                      <span class="ls-flag">{lang.flag}</span>
                      <span class="ls-name">{lang.name}</span>
                      <span class="ls-native">{lang.native}</span>
                      <%= if @native_lang && @native_lang.code == lang.code do %>
                        <span class="ls-check">✓</span>
                      <% end %>
                    </button>
                  <% end %>
                  <%= if filter_languages(Languages.all_languages(), @native_search) == [] do %>
                    <div class="ls-empty">No languages found</div>
                  <% end %>
                </div>
              </div>
            <% end %>
          </section>

          <div class="step-divider"></div>
          
    <!-- Step 2: Target Language -->
          <section class={["step", @native_lang == nil && "step-dim"]}>
            <div class="step-hd">
              <span class="step-n">02</span>
              <span class="step-label">I want to learn</span>
            </div>

            <%= if @native_lang do %>
              <div class="ls-wrap">
                <input
                  type="text"
                  phx-change="update_target_search"
                  value={@target_search}
                  name="search"
                  placeholder="Search a language to learn..."
                  class="ls-input"
                />
                <div class="ls-list">
                  <%= for lang <- filter_target_languages(@native_lang, Languages.all_languages(), @target_search) do %>
                    <button
                      phx-click="select_target"
                      phx-value-code={lang.code}
                      class={[
                        "ls-row",
                        @target_lang && @target_lang.code == lang.code && "ls-sel"
                      ]}
                    >
                      <span class="ls-flag">{lang.flag}</span>
                      <span class="ls-name">{lang.name}</span>
                      <span class="ls-native">{lang.native}</span>
                      <%= if @target_lang && @target_lang.code == lang.code do %>
                        <span class="ls-check">✓</span>
                      <% end %>
                    </button>
                  <% end %>
                  <%= if filter_target_languages(@native_lang, Languages.all_languages(), @target_search) == [] do %>
                    <div class="ls-empty">No languages found</div>
                  <% end %>
                </div>
              </div>
            <% else %>
              <p class="step-hint">Select your native language first</p>
            <% end %>
          </section>

          <div class="step-divider"></div>
          
    <!-- Step 3: CEFR Level -->
          <section class={["step", @target_lang == nil && "step-dim"]}>
            <div class="step-hd">
              <span class="step-n">03</span>
              <span class="step-label">My level</span>
            </div>

            <%= if @target_lang do %>
              <div class="cefr-grid">
                <%= for level <- Languages.cefr_levels() do %>
                  <button
                    phx-click="select_level"
                    phx-value-code={level.code}
                    class={[
                      "cefr-btn",
                      @cefr_level && @cefr_level.code == level.code && "cefr-on"
                    ]}
                  >
                    <span class="cefr-code">{level.label}</span>
                    <span class="cefr-desc">{level.desc}</span>
                  </button>
                <% end %>
              </div>
            <% else %>
              <p class="step-hint">Select a language to learn first</p>
            <% end %>
          </section>

          <div class="step-divider"></div>
          
    <!-- Step 4: Register -->
          <section class={["step", @cefr_level == nil && "step-dim"]}>
            <div class="step-hd">
              <span class="step-n">04</span>
              <span class="step-label">Register</span>
            </div>

            <%= if @cefr_level do %>
              <div class="register-grid">
                <%= for register <- Languages.registers() do %>
                  <button
                    phx-click="select_register"
                    phx-value-code={register.code}
                    class={[
                      "reg-btn",
                      @register && @register.code == register.code && "reg-on"
                    ]}
                  >
                    <span class="reg-icon">{register.icon}</span>
                    <span class="reg-label">{register.label}</span>
                    <span class="reg-desc">{register.desc}</span>
                  </button>
                <% end %>
              </div>
            <% else %>
              <p class="step-hint">Select your level first</p>
            <% end %>
          </section>
        </div>
        
    <!-- Start Button -->
        <button
          phx-click="start"
          disabled={!(@native_lang && @target_lang && @cefr_level && @register)}
          class={[
            "go-btn",
            @native_lang && @target_lang && @cefr_level && @register && "go-on"
          ]}
        >
          <%= if @native_lang && @target_lang && @cefr_level && @register do %>
            <span>
              Start {@register.label} {@target_lang.name} at {@cefr_level.code} {@target_lang.flag}
            </span>
            <span class="go-arr">→</span>
          <% else %>
            Complete all steps above
          <% end %>
        </button>
      </div>
    </div>
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
