defmodule DialektWeb.ChatLive do
  use DialektWeb, :live_view

  alias Dialekt.Languages
  alias Dialekt.References

  @starters %{
    "en" => ["Hello, how are you?", "Where is the nearest café?", "I'd like to order, please."],
    "es" => ["Hola, ¿cómo estás?", "¿Dónde está el café más cercano?", "Me gustaría pedir algo."],
    "fr" => [
      "Bonjour, comment allez-vous?",
      "Où est le café le plus proche?",
      "Je voudrais commander."
    ],
    "de" => [
      "Hallo, wie geht es Ihnen?",
      "Wo ist das nächste Café?",
      "Ich möchte etwas bestellen."
    ],
    "pt" => [
      "Olá, como vai você?",
      "Onde fica o café mais próximo?",
      "Gostaria de pedir, por favor."
    ],
    "zh" => ["你好，你好吗？", "最近的咖啡馆在哪里？", "我想点餐。"],
    "ja" => ["こんにちは、お元気ですか？", "一番近いカフェはどこですか？", "注文したいのですが。"],
    "ar" => ["مرحباً، كيف حالك؟", "أين أقرب مقهى؟", "أريد أن أطلب من فضلك."],
    "ru" => ["Здравствуйте, как вы?", "Где ближайшее кафе?", "Я хотел бы сделать заказ."],
    "ko" => ["안녕하세요, 어떻게 지내세요?", "가장 가까운 카페는 어디인가요?", "주문하고 싶어요."],
    "hi" => ["नमस्ते, आप कैसे हैं?", "निकटतम कैफे कहाँ है?", "मैं ऑर्डर करना चाहता हूँ।"],
    "it" => [
      "Buongiorno, come stai?",
      "Dov'è il caffè più vicino?",
      "Vorrei ordinare, per favore."
    ]
  }

  @default_starters [
    "Hello! How are you?",
    "Where is the train station?",
    "I'd like to order, please."
  ]

  @impl true
  def mount(params, _session, socket) do
    native = Languages.get_language(params["native"])
    target = Languages.get_language(params["target"])
    level = Languages.get_cefr_level(params["level"])
    register = Languages.get_register(params["register"])

    # Fetch reference data asynchronously
    if native && target do
      send(self(), :fetch_references)
    end

    {:ok,
     assign(socket,
       native: native,
       target: target,
       level: level,
       register: register,
       messages: [],
       input: "",
       ref_loading: true,
       ref_data: nil,
       ref_error: nil,
       show_ref_mobile: false
     )}
  end

  @impl true
  def handle_event("set_input", %{"text" => text}, socket) do
    {:noreply, assign(socket, input: text)}
  end

  @impl true
  def handle_event("send_starter", %{"text" => text}, socket) do
    message = %{role: "user", content: text, timestamp: DateTime.utc_now()}
    {:noreply, assign(socket, messages: socket.assigns.messages ++ [message])}
  end

  @impl true
  def handle_event("toggle_ref_mobile", _, socket) do
    {:noreply, assign(socket, show_ref_mobile: !socket.assigns.show_ref_mobile)}
  end

  @impl true
  def handle_info(:fetch_references, socket) do
    case References.fetch(socket.assigns.native, socket.assigns.target) do
      {:ok, data} ->
        {:noreply, assign(socket, ref_loading: false, ref_data: data, ref_error: nil)}

      {:error, error} ->
        {:noreply, assign(socket, ref_loading: false, ref_data: nil, ref_error: error)}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="chat-root">
      <%= if @show_ref_mobile do %>
        <div class="ref-backdrop" phx-click="toggle_ref_mobile"></div>
      <% end %>
      <div class="chat-app">
        <header class="chat-hdr">
          <button class="back-btn" phx-click={JS.navigate(~p"/")} type="button">←</button>
          <div class="hdr-info">
            <span class="hdr-pair">{@native && @native.flag} → {@target && @target.flag}</span>
            <span class="hdr-title">{@target && @target.name} Tutor</span>
          </div>
          <span class="hdr-badge">{@level && @level.code}</span>
          <span class="hdr-badge">{@register && @register.label}</span>
          <span class="hdr-badge">{@target && @target.native}</span>
          <button class="ref-toggle" phx-click="toggle_ref_mobile" type="button">
            <svg
              width="20"
              height="20"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              stroke-width="2"
              stroke-linecap="round"
              stroke-linejoin="round"
            >
              <line x1="3" y1="12" x2="21" y2="12"></line>
              <line x1="3" y1="6" x2="21" y2="6"></line>
              <line x1="3" y1="18" x2="21" y2="18"></line>
            </svg>
          </button>
        </header>

        <div class="chat-body">
          <%= if @messages == [] do %>
            <div class="empty">
              <div class="empty-flag">{@target && @target.flag}</div>
              <h2 class="empty-h">Ready to speak {@target && @target.name}?</h2>
              <p class="empty-p">
                Chat in <strong>{@target && @target.name}</strong>
                — or <strong>{@native && @native.name}</strong>
                if you're not ready yet.
              </p>
              <div class="starters">
                <%= for starter <- get_starters(@native) do %>
                  <button
                    type="button"
                    class="starter"
                    phx-click="send_starter"
                    phx-value-text={starter}
                  >
                    {starter}
                  </button>
                <% end %>
              </div>
            </div>
          <% else %>
            <%= for msg <- @messages do %>
              <div class="msg user-msg">
                <span class="av">{@native && @native.flag}</span>
                <div class="user-bubble">
                  <span class="user-text">{msg.content}</span>
                </div>
              </div>
            <% end %>
          <% end %>
        </div>

        <div class="input-area">
          <div class="input-row">
            <textarea
              class="chat-ta"
              placeholder={"Write in #{@native && @native.name} or try #{@target && @target.name}..."}
              rows="1"
            ></textarea>
            <button type="button" class="send-btn" disabled>
              <svg
                width="18"
                height="18"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                stroke-width="2.5"
                stroke-linecap="round"
                stroke-linejoin="round"
              >
                <line x1="22" y1="2" x2="11" y2="13" /><polygon points="22 2 15 22 11 13 2 9 22 2" />
              </svg>
            </button>
          </div>
          <div class="input-hint">↵ send · ⇧↵ new line</div>
        </div>
      </div>

      <aside class={["ref-sidebar", @show_ref_mobile && "ref-sidebar-open"]}>
        <div class="ref-hdr">
          <span class="ref-title">{@target && @target.flag} Quick Reference</span>
          <button class="ref-close" phx-click="toggle_ref_mobile" type="button">✕</button>
        </div>
        <div class="ref-body">
          <%= if @ref_loading do %>
            <div class="ref-loading">
              <span class="ld"></span>
              <span class="ld"></span>
              <span class="ld"></span>
              <p>Loading {@target && @target.name} reference...</p>
            </div>
          <% end %>

          <%= if @ref_error do %>
            <p class="ref-err">{@ref_error}</p>
          <% end %>

          <%= if @ref_data && !@ref_loading do %>
            <div class="ref-half">
              <div class="ref-section-title">Alphabet</div>
              <div class="ref-scroll">
                <div class="ref-alphabet">
                  <%= for item <- Map.get(@ref_data, "alphabet", []) do %>
                    <div class="ref-alpha-row">
                      <span class="ref-char">{item["char"]}</span>
                      <div class="ref-alpha-info">
                        <span class="ref-ipa">[{item["ipa"]}]</span>
                        <%= if item["hint"] do %>
                          <span class="ref-hint">{item["hint"]}</span>
                        <% end %>
                      </div>
                    </div>
                  <% end %>
                </div>
              </div>
            </div>
            <div class="ref-half">
              <div class="ref-section-title">Numbers</div>
              <div class="ref-scroll">
                <div class="ref-list">
                  <%= for item <- Map.get(@ref_data, "numbers", []) do %>
                    <div class="ref-row">
                      <span class="ref-native-word">{item["word"]}</span>
                      <div class="ref-target-info">
                        <span class="ref-target-word">{item["target"]}</span>
                        <span class="ref-ipa">
                          [{item["ipa"]}]{if item["hint"], do: " · #{item["hint"]}"}
                        </span>
                      </div>
                    </div>
                  <% end %>
                </div>
              </div>
            </div>
          <% end %>
        </div>
      </aside>
    </div>
    """
  end

  defp get_starters(native) do
    if native && Map.has_key?(@starters, native.code) do
      @starters[native.code]
    else
      @default_starters
    end
  end
end
