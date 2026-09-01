defmodule DialektWeb.ChatLiveTest do
  use DialektWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Dialekt.Learning

  describe "assistant response rendering" do
    test "escapes model-controlled HTML while preserving supported bold text", %{conn: conn} do
      {:ok, config} =
        Learning.create_config(%{
          name: "German Practice",
          native_language_code: "en",
          target_language_code: "de",
          cefr_level_code: "A2",
          register_code: "formal",
          starters: ["Hello"]
        })

      {:ok, session} = Learning.create_session(config.id)

      raw_response = """
      ```
      You:
      German: **Hallo** <script id="phrase-xss">alert(1)</script> - [halo] (halo)
      Note: <img id="note-xss" src="x" onerror="alert(1)">
      Tutor:
      German: **Guten Tag** <svg id="tutor-xss" onload="alert(1)"></svg> - [guːtn̩ taːk] (goo-ten tahk)
      Hello
      Follow-up:
      German: Wie geht es <iframe id="followup-xss"></iframe>? - [viː geːt ɛs] (vee gate ess)
      How are you?
      Tips: <details id="tips-xss" open ontoggle="alert(1)">tip</details>
      ```
      """

      timestamp = DateTime.utc_now() |> DateTime.truncate(:second) |> DateTime.to_iso8601()

      {:ok, _session} =
        Learning.update_session_messages(session, [
          %{
            "role" => "assistant",
            "content" => raw_response,
            "text" => raw_response,
            "raw_response" => raw_response,
            "timestamp" => timestamp
          }
        ])

      {:ok, view, html} = live(conn, ~p"/chat?session_id=#{session.id}")

      assert has_element?(view, ".tutor-section-you strong", "Hallo")
      assert has_element?(view, ".tutor-section-response strong", "Guten Tag")
      assert has_element?(view, "#chat-review-link[href='/review/#{config.id}']")
      refute has_element?(view, "#phrase-xss")
      refute has_element?(view, "#note-xss")
      refute has_element?(view, "#tutor-xss")
      refute has_element?(view, "#followup-xss")
      refute has_element?(view, "#tips-xss")
      assert html =~ "&lt;script id=&quot;phrase-xss&quot;&gt;"
    end
  end
end
