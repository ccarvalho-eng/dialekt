defmodule DialektWeb.SetupLive do
  use DialektWeb, :live_view

  alias Dialekt.Languages

  @impl true
  def mount(_params, _session, socket) do
    theme = get_connect_params(socket)["theme"] || "light"

    {:ok,
     assign(socket,
       native_lang: nil,
       target_lang: nil,
       cefr_level: nil,
       register: nil,
       show_native_search: false,
       native_search: "",
       target_search: "",
       theme: theme
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

  def handle_event("toggle_theme", _, socket) do
    new_theme = if socket.assigns.theme == "dark", do: "light", else: "dark"

    {:noreply,
     socket
     |> assign(theme: new_theme)
     |> push_event("update-theme", %{theme: new_theme})}
  end

  def handle_event("sync_theme", %{"theme" => theme}, socket) do
    {:noreply, assign(socket, theme: theme)}
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
