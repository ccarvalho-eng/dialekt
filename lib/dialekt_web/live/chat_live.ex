defmodule DialektWeb.ChatLive do
  use DialektWeb, :live_view

  alias Dialekt.Languages
  alias Dialekt.Learning
  alias Dialekt.Tutor

  @starters %{
    "en" => [
      "Hello, how are you?",
      "Where is the nearest café?",
      "I'd like to order, please.",
      "What time does the museum open?",
      "How much does this cost?",
      "Can you recommend a good restaurant?",
      "I'm looking for the bathroom.",
      "Do you speak English?",
      "I need help with directions.",
      "What's the weather like today?"
    ],
    "es" => [
      "Hola, ¿cómo estás?",
      "¿Dónde está el café más cercano?",
      "Me gustaría pedir algo.",
      "¿A qué hora abre el museo?",
      "¿Cuánto cuesta esto?",
      "¿Puedes recomendar un buen restaurante?",
      "Estoy buscando el baño.",
      "¿Hablas español?",
      "Necesito ayuda con direcciones.",
      "¿Qué tiempo hace hoy?"
    ],
    "fr" => [
      "Bonjour, comment allez-vous?",
      "Où est le café le plus proche?",
      "Je voudrais commander.",
      "À quelle heure ouvre le musée?",
      "Combien ça coûte?",
      "Pouvez-vous recommander un bon restaurant?",
      "Je cherche les toilettes.",
      "Parlez-vous français?",
      "J'ai besoin d'aide pour les directions.",
      "Quel temps fait-il aujourd'hui?"
    ],
    "de" => [
      "Hallo, wie geht es Ihnen?",
      "Wo ist das nächste Café?",
      "Ich möchte etwas bestellen.",
      "Wann öffnet das Museum?",
      "Wie viel kostet das?",
      "Können Sie ein gutes Restaurant empfehlen?",
      "Ich suche die Toilette.",
      "Sprechen Sie Deutsch?",
      "Ich brauche Hilfe mit der Wegbeschreibung.",
      "Wie ist das Wetter heute?"
    ],
    "pt" => [
      "Olá, como vai você?",
      "Onde fica o café mais próximo?",
      "Gostaria de pedir, por favor.",
      "A que horas abre o museu?",
      "Quanto custa isso?",
      "Pode recomendar um bom restaurante?",
      "Estou procurando o banheiro.",
      "Você fala português?",
      "Preciso de ajuda com direções.",
      "Como está o tempo hoje?"
    ],
    "zh" => [
      "你好，你好吗？",
      "最近的咖啡馆在哪里？",
      "我想点餐。",
      "博物馆几点开门？",
      "这个多少钱？",
      "你能推荐一家好餐厅吗？",
      "我在找洗手间。",
      "你会说中文吗？",
      "我需要问路。",
      "今天天气怎么样？"
    ],
    "ja" => [
      "こんにちは、お元気ですか？",
      "一番近いカフェはどこですか？",
      "注文したいのですが。",
      "博物館は何時に開きますか？",
      "これはいくらですか？",
      "良いレストランをおすすめできますか？",
      "トイレを探しています。",
      "日本語を話せますか？",
      "道順を教えてください。",
      "今日の天気はどうですか？"
    ],
    "ar" => [
      "مرحباً، كيف حالك؟",
      "أين أقرب مقهى؟",
      "أريد أن أطلب من فضلك.",
      "متى يفتح المتحف؟",
      "كم سعر هذا؟",
      "هل يمكنك أن توصي بمطعم جيد؟",
      "أبحث عن الحمام.",
      "هل تتكلم العربية؟",
      "أحتاج مساعدة في الاتجاهات.",
      "كيف الطقس اليوم؟"
    ],
    "ru" => [
      "Здравствуйте, как вы?",
      "Где ближайшее кафе?",
      "Я хотел бы сделать заказ.",
      "Во сколько открывается музей?",
      "Сколько это стоит?",
      "Можете порекомендовать хороший ресторан?",
      "Я ищу туалет.",
      "Вы говорите по-русски?",
      "Мне нужна помощь с направлениями.",
      "Какая сегодня погода?"
    ],
    "ko" => [
      "안녕하세요, 어떻게 지내세요?",
      "가장 가까운 카페는 어디인가요?",
      "주문하고 싶어요.",
      "박물관은 몇 시에 열어요?",
      "이거 얼마예요?",
      "좋은 식당을 추천해 주실 수 있나요?",
      "화장실을 찾고 있어요.",
      "한국어 할 수 있어요?",
      "길 안내가 필요해요.",
      "오늘 날씨가 어때요?"
    ],
    "hi" => [
      "नमस्ते, आप कैसे हैं?",
      "निकटतम कैफे कहाँ है?",
      "मैं ऑर्डर करना चाहता हूँ।",
      "संग्रहालय कब खुलता है?",
      "यह कितने का है?",
      "क्या आप एक अच्छे रेस्तरां की सिफारिश कर सकते हैं?",
      "मैं बाथरूम ढूंढ रहा हूँ।",
      "क्या आप हिंदी बोलते हैं?",
      "मुझे दिशा-निर्देश में मदद चाहिए।",
      "आज मौसम कैसा है?"
    ],
    "it" => [
      "Buongiorno, come stai?",
      "Dov'è il caffè più vicino?",
      "Vorrei ordinare, per favore.",
      "A che ora apre il museo?",
      "Quanto costa questo?",
      "Puoi consigliare un buon ristorante?",
      "Sto cercando il bagno.",
      "Parli italiano?",
      "Ho bisogno di aiuto con le indicazioni.",
      "Che tempo fa oggi?"
    ]
  }

  @default_starters [
    "Hello, how are you?",
    "Where is the train station?",
    "I'd like to order, please.",
    "What time does the museum open?",
    "How much does this cost?",
    "Can you recommend a good restaurant?",
    "I'm looking for the bathroom.",
    "Do you speak English?",
    "I need help with directions.",
    "What's the weather like today?"
  ]

  @impl true
  def mount(params, _session, socket) do
    session_id = params["session_id"]

    if session_id do
      mount_with_session(socket, session_id)
    else
      mount_with_params(socket, params)
    end
  end

  defp mount_with_session(socket, session_id) do
    try do
      session = Learning.get_session!(String.to_integer(session_id))
      config = Learning.get_config!(session.config_id)

      native = Languages.get_language(config.native_language_code)
      target = Languages.get_language(config.target_language_code)
      level = Languages.get_cefr_level(config.cefr_level_code)
      register = Languages.get_register(config.register_code)

      messages = convert_persisted_messages(session.messages)

      send(self(), :fetch_starters)

      {:ok,
       assign(socket,
         chat_session: session,
         config: config,
         native: native,
         target: target,
         level: level,
         register: register,
         messages: messages,
         input: "",
         starters: get_random_starters(native)
       )}
    rescue
      Ecto.NoResultsError ->
        {:ok,
         socket
         |> put_flash(:error, "Session not found")
         |> push_navigate(to: ~p"/dashboard")}
    end
  end

  defp mount_with_params(socket, params) do
    native = Languages.get_language(params["native"])
    target = Languages.get_language(params["target"])
    level = Languages.get_cefr_level(params["level"])
    register = Languages.get_register(params["register"])

    # Create config and session for persistence
    chat_session =
      if native && target && level && register do
        {:ok, config} =
          Learning.create_config(%{
            name: "#{target.name} Practice",
            native_language_code: native.code,
            target_language_code: target.code,
            cefr_level_code: level.code,
            register_code: register.code
          })

        {:ok, session} = Learning.create_session(config.id)
        session
      else
        nil
      end

    if native && target && level do
      send(self(), :fetch_starters)
    end

    {:ok,
     assign(socket,
       chat_session: chat_session,
       config: nil,
       native: native,
       target: target,
       level: level,
       register: register,
       messages: [],
       input: "",
       starters: get_random_starters(native)
     )}
  end

  defp convert_persisted_messages(persisted_messages) do
    Enum.map(persisted_messages, fn msg ->
      %{
        role: msg["role"],
        content: msg["content"],
        text: msg["text"],
        raw_response: msg["raw_response"],
        timestamp: parse_timestamp(msg["timestamp"])
      }
    end)
  end

  defp parse_timestamp(nil), do: DateTime.utc_now()

  defp parse_timestamp(timestamp) when is_binary(timestamp) do
    case DateTime.from_iso8601(timestamp) do
      {:ok, dt, _offset} -> dt
      _ -> DateTime.utc_now()
    end
  end

  defp parse_timestamp(_), do: DateTime.utc_now()

  @impl true
  def handle_event("set_input", %{"text" => text}, socket) do
    {:noreply, assign(socket, input: text)}
  end

  @impl true
  def handle_event("update_input", %{"value" => value}, socket) do
    {:noreply, assign(socket, input: value)}
  end

  @impl true
  def handle_event("send_starter", %{"text" => text}, socket) do
    user_message = %{
      role: "user",
      content: text,
      text: text,
      timestamp: DateTime.utc_now()
    }

    loading_message = %{
      role: "assistant",
      content: "",
      loading: true,
      timestamp: DateTime.utc_now()
    }

    updated_socket =
      socket
      |> assign(messages: socket.assigns.messages ++ [user_message, loading_message])

    send(self(), {:get_tutor_response, text, length(socket.assigns.messages)})

    {:noreply, updated_socket}
  end

  @impl true
  def handle_event("send_message", _, socket) do
    input = String.trim(socket.assigns.input)

    if input == "" do
      {:noreply, socket}
    else
      # Add user message
      user_message = %{
        role: "user",
        content: input,
        text: input,
        timestamp: DateTime.utc_now()
      }

      # Add loading message
      loading_message = %{
        role: "assistant",
        content: "",
        loading: true,
        timestamp: DateTime.utc_now()
      }

      updated_socket =
        socket
        |> assign(messages: socket.assigns.messages ++ [user_message, loading_message])
        |> assign(input: "")

      # Send async message to get AI response
      send(self(), {:get_tutor_response, input, length(socket.assigns.messages)})

      {:noreply, updated_socket}
    end
  end

  @impl true
  def handle_info(:fetch_starters, socket) do
    case Tutor.generate_starters(
           socket.assigns.native,
           socket.assigns.target,
           socket.assigns.level
         ) do
      {:ok, starters} ->
        {:noreply, assign(socket, starters: starters)}

      {:error, _error} ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:get_tutor_response, user_input, _message_index}, socket) do
    context = %{
      native: socket.assigns.native,
      target: socket.assigns.target,
      level: socket.assigns.level,
      register: socket.assigns.register,
      history: build_history(socket.assigns.messages)
    }

    case Tutor.chat(user_input, context) do
      {:ok, parsed, raw_response} ->
        # Remove loading message and add real response
        messages_without_loading = Enum.reject(socket.assigns.messages, &Map.get(&1, :loading))

        assistant_message = %{
          role: "assistant",
          content: raw_response,
          parsed: parsed,
          raw_response: raw_response,
          timestamp: DateTime.utc_now()
        }

        all_messages = messages_without_loading ++ [assistant_message]

        # Persist messages if we have a session
        socket =
          if socket.assigns.chat_session do
            persist_messages(socket, all_messages)
          else
            socket
          end

        {:noreply, assign(socket, messages: all_messages)}

      {:error, error} ->
        # Remove loading message and add error
        messages_without_loading = Enum.reject(socket.assigns.messages, &Map.get(&1, :loading))

        error_message = %{
          role: "assistant",
          content: "Error: #{error}",
          error: true,
          timestamp: DateTime.utc_now()
        }

        {:noreply, assign(socket, messages: messages_without_loading ++ [error_message])}
    end
  end

  defp persist_messages(socket, messages) do
    # Convert messages to persistable format (remove parsed field, etc.)
    persistable_messages =
      Enum.map(messages, fn msg ->
        %{
          "role" => msg.role,
          "content" => msg[:content] || msg[:text] || "",
          "text" => msg[:text] || msg[:content] || "",
          "raw_response" => msg[:raw_response],
          "timestamp" => DateTime.to_iso8601(msg.timestamp)
        }
      end)

    # Update session with all messages
    session = socket.assigns.chat_session
    fresh_session = Learning.get_session!(session.id)
    {:ok, updated_session} = Learning.update_session_messages(fresh_session, persistable_messages)

    assign(socket, chat_session: updated_session)
  end

  defp build_history(messages) do
    messages
    |> Enum.reject(&Map.get(&1, :loading))
    |> Enum.map(fn msg ->
      %{
        role: msg.role,
        text: msg[:text] || msg[:content] || "",
        raw_response: msg[:raw_response]
      }
    end)
  end

  defp render_tutor_response(assigns, msg) do
    parsed = msg[:parsed]

    if parsed && parsed.raw do
      # Fallback: show raw content
      ~H"""
      <div style="white-space: pre-wrap; font-size: 0.85rem;">{parsed.raw}</div>
      """
    else
      ~H"""
      <%= if parsed do %>
        <%= if parsed.you && parsed.you.phrase && parsed.you.phrase != "" do %>
          <div style="margin-bottom: 12px;">
            <div style="font-weight: 600; font-size: 0.75rem; color: var(--text-muted); margin-bottom: 4px;">
              In {@target && @target.name}:
            </div>
            <div style="font-size: 0.9rem;">{parsed.you.phrase}</div>
            <%= if parsed.you.ipa != "" do %>
              <div style="font-size: 0.75rem; color: var(--text-dim); margin-top: 2px;">
                [{parsed.you.ipa}] {parsed.you.roman != "" && "(#{parsed.you.roman})"}
              </div>
            <% end %>
          </div>
        <% end %>
        <%= if parsed.note && parsed.note != "" do %>
          <div style="background: var(--surface2); padding: 8px 12px; border-radius: 6px; margin-bottom: 12px; font-size: 0.85rem; color: var(--text-dim);">
            💡 {parsed.note}
          </div>
        <% end %>
        <%= if parsed.tutor && length(parsed.tutor) > 0 do %>
          <div style="margin-bottom: 12px;">
            <div style="font-weight: 600; font-size: 0.75rem; color: var(--text-muted); margin-bottom: 4px;">
              Tutor:
            </div>
            <%= for line <- parsed.tutor do %>
              <div style="margin-bottom: 8px;">
                <div style="font-size: 0.9rem;" phx-no-format><%= raw(format_bold(line.phrase)) %></div>
                <%= if line.ipa != "" do %>
                  <div style="font-size: 0.75rem; color: var(--text-dim); margin-top: 2px;">
                    [{line.ipa}] {line.roman != "" && "(#{line.roman})"}
                  </div>
                <% end %>
                <%= if line.translation != "" do %>
                  <div style="font-size: 0.8rem; color: var(--text-muted); margin-top: 4px; font-style: italic;">
                    {line.translation}
                  </div>
                <% end %>
              </div>
            <% end %>
          </div>
        <% end %>
        <%= if parsed.followup do %>
          <div style="margin-bottom: 8px;">
            <div style="font-weight: 600; font-size: 0.75rem; color: var(--text-muted); margin-bottom: 4px;">
              Follow-up:
            </div>
            <div style="font-size: 0.9rem;">{parsed.followup.phrase}</div>
            <%= if parsed.followup.ipa != "" do %>
              <div style="font-size: 0.75rem; color: var(--text-dim); margin-top: 2px;">
                [{parsed.followup.ipa}] {parsed.followup.roman != "" && "(#{parsed.followup.roman})"}
              </div>
            <% end %>
            <%= if parsed.followup.translation != "" do %>
              <div style="font-size: 0.8rem; color: var(--text-muted); margin-top: 4px; font-style: italic;">
                {parsed.followup.translation}
              </div>
            <% end %>
          </div>
        <% end %>
        <%= if parsed.tips && parsed.tips != "" do %>
          <div style="background: var(--surface2); padding: 8px 12px; border-radius: 6px; margin-top: 12px; font-size: 0.85rem; color: var(--text-dim);">
            💡 {parsed.tips}
          </div>
        <% end %>
      <% else %>
        <div style="white-space: pre-wrap; font-size: 0.85rem;">{msg.content}</div>
      <% end %>
      """
    end
  end

  defp format_bold(text) do
    text
    |> String.replace(~r/\*\*(.+?)\*\*/, "<strong>\\1</strong>")
  end

  defp get_random_starters(native) do
    all_starters =
      if native && Map.has_key?(@starters, native.code) do
        @starters[native.code]
      else
        @default_starters
      end

    all_starters
    |> Enum.shuffle()
    |> Enum.take(3)
  end
end
