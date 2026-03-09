defmodule DialektWeb.ChatLive do
  use DialektWeb, :live_view

  alias Dialekt.Languages
  alias Dialekt.Learning
  alias Dialekt.Tutor

  @hardcoded_starters %{
    "en" => [
      "Hello, how are you?",
      "How's your day going?",
      "Nice to meet you!",
      "What's your name?",
      "How have you been?",
      "What did you do today?",
      "Good morning!",
      "How are things?",
      "What's new?",
      "Great to see you!"
    ],
    "es" => [
      "Hola, ¿cómo estás?",
      "¿Cómo va tu día?",
      "¡Mucho gusto!",
      "¿Cómo te llamas?",
      "¿Qué tal todo?",
      "¿Qué hiciste hoy?",
      "¡Buenos días!",
      "¿Cómo te va?",
      "¿Qué hay de nuevo?",
      "¡Encantado de verte!"
    ],
    "fr" => [
      "Bonjour, comment ça va?",
      "Comment se passe ta journée?",
      "Enchanté!",
      "Comment tu t'appelles?",
      "Comment vas-tu?",
      "Qu'as-tu fait aujourd'hui?",
      "Bonjour!",
      "Comment ça se passe?",
      "Quoi de neuf?",
      "Ravi de te voir!"
    ],
    "de" => [
      "Hallo, wie geht's?",
      "Wie läuft dein Tag?",
      "Freut mich!",
      "Wie heißt du?",
      "Wie geht es dir?",
      "Was hast du heute gemacht?",
      "Guten Morgen!",
      "Wie läuft's?",
      "Was gibt's Neues?",
      "Schön dich zu sehen!"
    ],
    "pt" => [
      "Olá, como vai?",
      "Como está seu dia?",
      "Prazer em conhecer!",
      "Qual é seu nome?",
      "Como você está?",
      "O que você fez hoje?",
      "Bom dia!",
      "Como vão as coisas?",
      "O que há de novo?",
      "Que bom te ver!"
    ],
    "zh" => [
      "你好，你好吗？",
      "你今天怎么样？",
      "很高兴认识你！",
      "你叫什么名字？",
      "你最近怎么样？",
      "你今天做了什么？",
      "早上好！",
      "一切都好吗？",
      "有什么新鲜事吗？",
      "见到你真好！"
    ],
    "ja" => [
      "こんにちは、元気ですか？",
      "今日はどうですか？",
      "はじめまして！",
      "お名前は何ですか？",
      "最近どうですか？",
      "今日は何をしましたか？",
      "おはようございます！",
      "調子はどうですか？",
      "何か新しいことはありますか？",
      "会えて嬉しいです！"
    ],
    "ar" => [
      "مرحبا، كيف حالك؟",
      "كيف يومك؟",
      "تشرفنا!",
      "ما اسمك؟",
      "كيف كنت؟",
      "ماذا فعلت اليوم؟",
      "صباح الخير!",
      "كيف الأحوال؟",
      "ما الجديد؟",
      "سعيد برؤيتك!"
    ],
    "ru" => [
      "Привет, как дела?",
      "Как твой день?",
      "Приятно познакомиться!",
      "Как тебя зовут?",
      "Как ты?",
      "Что ты делал сегодня?",
      "Доброе утро!",
      "Как жизнь?",
      "Что нового?",
      "Рад тебя видеть!"
    ],
    "hi" => [
      "नमस्ते, कैसे हो?",
      "आपका दिन कैसा है?",
      "आपसे मिलकर खुशी हुई!",
      "आपका नाम क्या है?",
      "आप कैसे हैं?",
      "आपने आज क्या किया?",
      "सुप्रभात!",
      "सब कैसा चल रहा है?",
      "क्या नया है?",
      "आपको देखकर अच्छा लगा!"
    ],
    "ko" => [
      "안녕하세요, 어떻게 지내세요?",
      "오늘 어떠세요?",
      "만나서 반갑습니다!",
      "이름이 뭐예요?",
      "요즘 어떻게 지내요?",
      "오늘 뭐 했어요?",
      "좋은 아침이에요!",
      "어떻게 지내요?",
      "무슨 일 있어요?",
      "만나서 기뻐요!"
    ],
    "it" => [
      "Ciao, come stai?",
      "Come va la tua giornata?",
      "Piacere di conoscerti!",
      "Come ti chiami?",
      "Come stai?",
      "Cosa hai fatto oggi?",
      "Buongiorno!",
      "Come vanno le cose?",
      "Cosa c'è di nuovo?",
      "Felice di vederti!"
    ]
  }

  @default_starters [
    "Hello, how are you?",
    "How's your day going?",
    "Nice to meet you!",
    "What's your name?",
    "How have you been?",
    "What did you do today?",
    "Good morning!",
    "How are things?",
    "What's new?",
    "Great to see you!"
  ]

  @impl true
  def mount(params, _session, socket) do
    session_id = params["session_id"]
    theme = get_connect_params(socket)["theme"] || "light"

    socket = assign(socket, theme: theme)

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

      # Get initial starters (cached, hardcoded, or trigger AI)
      starters = get_initial_starters(config, native)

      # Get all sessions for this config
      all_sessions = Learning.list_sessions_for_config(config.id)

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
         starters: starters,
         all_sessions: all_sessions,
         deleting_session_id: nil
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
    {chat_session, config, all_sessions} =
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
        all_sessions = Learning.list_sessions_for_config(config.id)
        {session, config, all_sessions}
      else
        {nil, nil, []}
      end

    # Get initial starters (cached, hardcoded, or trigger AI)
    starters =
      if config && native do
        get_initial_starters(config, native)
      else
        []
      end

    {:ok,
     assign(socket,
       chat_session: chat_session,
       config: config,
       native: native,
       target: target,
       level: level,
       register: register,
       messages: [],
       input: "",
       starters: starters,
       all_sessions: all_sessions,
       deleting_session_id: nil
     )}
  end

  defp convert_persisted_messages(persisted_messages) do
    Enum.map(persisted_messages, fn msg ->
      base_msg = %{
        role: msg["role"],
        content: msg["content"],
        text: msg["text"],
        raw_response: msg["raw_response"],
        timestamp: parse_timestamp(msg["timestamp"])
      }

      # Add error flag if present
      base_msg = if msg["error"], do: Map.put(base_msg, :error, true), else: base_msg

      # Re-parse assistant messages for rendering (skip if it's an error message)
      if msg["role"] == "assistant" && msg["raw_response"] && msg["raw_response"] != "" &&
           !msg["error"] do
        parsed = Tutor.parse_response(msg["raw_response"])
        Map.put(base_msg, :parsed, parsed)
      else
        base_msg
      end
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

    updated_messages = socket.assigns.messages ++ [user_message, loading_message]

    updated_socket =
      socket
      |> assign(messages: updated_messages)

    # Persist user message immediately
    updated_socket =
      if socket.assigns.chat_session do
        persist_messages(updated_socket, updated_messages)
      else
        updated_socket
      end

    send(self(), {:get_tutor_response, text, length(socket.assigns.messages)})

    {:noreply, updated_socket}
  end

  @impl true
  def handle_event("switch_session", %{"session-id" => session_id}, socket) do
    {:noreply, push_navigate(socket, to: ~p"/chat?session_id=#{session_id}")}
  end

  @impl true
  def handle_event("new_session", _, socket) do
    if socket.assigns.config do
      {:ok, new_session} = Learning.create_session(socket.assigns.config.id)
      {:noreply, push_navigate(socket, to: ~p"/chat?session_id=#{new_session.id}")}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("show_delete_session", %{"session-id" => session_id}, socket) do
    {:noreply, assign(socket, deleting_session_id: String.to_integer(session_id))}
  end

  @impl true
  def handle_event("delete_session_from_sidebar", _, socket) do
    if socket.assigns.deleting_session_id do
      session = Learning.get_session!(socket.assigns.deleting_session_id)
      {:ok, _} = Learning.delete_session(session)

      # Refresh sessions list
      all_sessions =
        if socket.assigns.config do
          Learning.list_sessions_for_config(socket.assigns.config.id)
        else
          []
        end

      # If we deleted the current session, redirect to dashboard
      if socket.assigns.chat_session && socket.assigns.chat_session.id == session.id do
        {:noreply, push_navigate(socket, to: ~p"/dashboard")}
      else
        {:noreply, assign(socket, all_sessions: all_sessions, deleting_session_id: nil)}
      end
    else
      {:noreply, socket}
    end
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

      updated_messages = socket.assigns.messages ++ [user_message, loading_message]

      # Persist user message immediately
      updated_socket =
        socket
        |> assign(messages: updated_messages)
        |> assign(input: "")

      updated_socket =
        if socket.assigns.chat_session do
          persist_messages(updated_socket, updated_messages)
        else
          updated_socket
        end

      # Send async message to get AI response
      send(self(), {:get_tutor_response, input, length(socket.assigns.messages)})

      {:noreply, updated_socket}
    end
  end

  @impl true
  def handle_event("toggle_theme", _, socket) do
    new_theme = if socket.assigns.theme == "dark", do: "light", else: "dark"

    {:noreply,
     socket
     |> assign(theme: new_theme)
     |> push_event("update-theme", %{theme: new_theme})}
  end

  @impl true
  def handle_event("sync_theme", %{"theme" => theme}, socket) do
    {:noreply, assign(socket, theme: theme)}
  end

  @impl true
  def handle_info(:fetch_starters, socket) do
    case Tutor.generate_starters(
           socket.assigns.native,
           socket.assigns.target,
           socket.assigns.level
         ) do
      {:ok, starters} ->
        # Cache AI-generated starters to config for future sessions
        if socket.assigns.config do
          Learning.update_config_starters(socket.assigns.config, starters)
        end

        {:noreply, assign(socket, starters: starters)}

      {:error, _error} ->
        # On error, fallback to default starters if available
        fallback_starters =
          if socket.assigns.native &&
               Map.has_key?(@hardcoded_starters, socket.assigns.native.code) do
            get_random_starters(socket.assigns.native)
          else
            Enum.take(@default_starters, 3)
          end

        {:noreply, assign(socket, starters: fallback_starters)}
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

        all_messages = messages_without_loading ++ [error_message]

        # Persist messages including error
        socket =
          if socket.assigns.chat_session do
            persist_messages(socket, all_messages)
          else
            socket
          end

        {:noreply, assign(socket, messages: all_messages)}
    end
  end

  defp persist_messages(socket, messages) do
    # Convert messages to persistable format (remove loading messages and parsed field)
    persistable_messages =
      messages
      |> Enum.reject(&Map.get(&1, :loading))
      |> Enum.map(fn msg ->
        %{
          "role" => msg.role,
          "content" => msg[:content] || msg[:text] || "",
          "text" => msg[:text] || msg[:content] || "",
          "raw_response" => msg[:raw_response],
          "error" => msg[:error],
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
    assigns = assign(assigns, :parsed, msg[:parsed])
    assigns = assign(assigns, :msg, msg)

    ~H"""
    <%= if @parsed && @parsed.raw do %>
      <div style="white-space: pre-wrap; font-size: 0.85rem;">{@parsed.raw}</div>
    <% else %>
      <%= if @parsed do %>
        <%= if @parsed.you && @parsed.you.phrase && @parsed.you.phrase != "" do %>
          <div style="margin-bottom: 12px;">
            <div style="font-weight: 600; font-size: 0.75rem; color: var(--text-muted); margin-bottom: 4px;">
              In {@target && @target.name}:
            </div>
            <div style="display: flex; align-items: center; gap: 8px;">
              <div style="font-size: 0.9rem; flex: 1;" phx-no-format><%= raw(format_bold(@parsed.you.phrase)) %></div>
              <button
                id={"tts-you-#{DateTime.to_unix(@msg.timestamp, :microsecond)}"}
                phx-hook="TextToSpeech"
                data-text={@parsed.you.phrase}
                data-lang={@target && @target.code}
                type="button"
                style="background: none; border: none; cursor: pointer; padding: 4px; font-size: 1rem; opacity: 0.6; transition: opacity 0.2s;"
                onmouseover="this.style.opacity='1'"
                onmouseout="this.style.opacity='0.6'"
                title="Listen"
              >
                🔊
              </button>
            </div>
            <%= if @parsed.you.ipa != "" do %>
              <div style="font-size: 0.75rem; color: var(--text-dim); margin-top: 2px;">
                [{@parsed.you.ipa}] {@parsed.you.roman != "" && "(#{@parsed.you.roman})"}
              </div>
            <% end %>
          </div>
        <% end %>
        <%= if @parsed.note && @parsed.note != "" do %>
          <div
            style="background: var(--surface2); padding: 8px 12px; border-radius: 6px; margin-bottom: 12px; font-size: 0.85rem; color: var(--text-dim);"
            phx-no-format
          >
            💡 <%= raw(format_bold(@parsed.note)) %>
          </div>
        <% end %>
        <%= if @parsed.tutor && length(@parsed.tutor) > 0 do %>
          <div style="margin-bottom: 12px;">
            <div style="font-weight: 600; font-size: 0.75rem; color: var(--text-muted); margin-bottom: 4px;">
              Tutor:
            </div>
            <%= for line <- @parsed.tutor do %>
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
        <%= if @parsed.followup do %>
          <div style="margin-bottom: 8px;">
            <div style="font-weight: 600; font-size: 0.75rem; color: var(--text-muted); margin-bottom: 4px;">
              Follow-up:
            </div>
            <div style="font-size: 0.9rem;" phx-no-format><%= raw(format_bold(@parsed.followup.phrase)) %></div>
            <%= if @parsed.followup.ipa != "" do %>
              <div style="font-size: 0.75rem; color: var(--text-dim); margin-top: 2px;">
                [{@parsed.followup.ipa}] {@parsed.followup.roman != "" &&
                  "(#{@parsed.followup.roman})"}
              </div>
            <% end %>
            <%= if @parsed.followup.translation != "" do %>
              <div style="font-size: 0.8rem; color: var(--text-muted); margin-top: 4px; font-style: italic;">
                {@parsed.followup.translation}
              </div>
            <% end %>
          </div>
        <% end %>
        <%= if @parsed.tips && @parsed.tips != "" do %>
          <div
            style="background: var(--surface2); padding: 8px 12px; border-radius: 6px; margin-top: 12px; font-size: 0.85rem; color: var(--text-dim);"
            phx-no-format
          >
            💡 <%= raw(format_bold(@parsed.tips)) %>
          </div>
        <% end %>
      <% else %>
        <div style="white-space: pre-wrap; font-size: 0.85rem;">{@msg.content}</div>
      <% end %>
    <% end %>
    """
  end

  defp format_bold(text) do
    text
    |> String.replace(~r/\*\*(.+?)\*\*/, "<strong>\\1</strong>")
  end

  defp get_initial_starters(config, native) do
    cond do
      # If config has cached starters, use them
      config.starters && length(config.starters) > 0 ->
        config.starters

      # If native language has hardcoded starters, use them and cache
      native && Map.has_key?(@hardcoded_starters, native.code) ->
        starters = get_random_starters(native)
        # Cache hardcoded starters to config
        Learning.update_config_starters(config, starters)
        starters

      # No hardcoded or cached, trigger AI generation
      true ->
        send(self(), :fetch_starters)
        []
    end
  end

  defp get_random_starters(native) do
    all_starters =
      if native && Map.has_key?(@hardcoded_starters, native.code) do
        @hardcoded_starters[native.code]
      else
        @default_starters
      end

    all_starters
    |> Enum.shuffle()
    |> Enum.take(3)
  end
end
