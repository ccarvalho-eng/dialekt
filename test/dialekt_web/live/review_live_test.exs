defmodule DialektWeb.ReviewLiveTest do
  use DialektWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Dialekt.Learning

  describe "review queue" do
    setup do
      {:ok, config} = create_config("Spanish Practice", "es")
      %{config: config}
    end

    test "shows the active empty state and URL-backed filters", %{conn: conn, config: config} do
      {:ok, view, _html} = live(conn, ~p"/review/#{config.id}")
      html = render_async(view)

      assert html =~ "No active mistakes"
      assert has_element?(view, "#review-filter-active.is-active")
      assert has_element?(view, "#review-filter-learned")
      assert has_element?(view, "#review-filter-all")
    end

    test "renders escaped correction content with language metadata", %{
      conn: conn,
      config: config
    } do
      {:ok, mistake} =
        create_mistake(
          config.id,
          ~s|<script id="original-xss">alert(1)</script>|,
          ~s|<img id="correction-xss" src="x">|
        )

      {:ok, view, _html} = live(conn, ~p"/review/#{config.id}")
      html = render_async(view)

      assert has_element?(view, "#mistake-#{mistake.id} [lang='es'][dir='ltr']")
      refute has_element?(view, "#original-xss")
      refute has_element?(view, "#correction-xss")
      assert html =~ "&lt;script id=&quot;original-xss&quot;&gt;"
    end

    test "marks a mistake learned, filters it, and restores it", %{conn: conn, config: config} do
      {:ok, mistake} = create_mistake(config.id, "Como estas", "¿Cómo estás?")
      {:ok, view, _html} = live(conn, ~p"/review/#{config.id}")
      render_async(view)

      view
      |> element("#mark-learned-#{mistake.id}")
      |> render_click()

      render_async(view)
      refute has_element?(view, "#mistake-#{mistake.id}")
      assert Learning.get_mistake_for_config!(config.id, mistake.id).learned_at

      view
      |> element("#review-filter-learned")
      |> render_click()

      assert_patch(view, ~p"/review/#{config.id}?status=learned")
      render_async(view)
      assert has_element?(view, "#restore-mistake-#{mistake.id}")

      view
      |> element("#restore-mistake-#{mistake.id}")
      |> render_click()

      render_async(view)
      refute has_element?(view, "#mistake-#{mistake.id}")
      assert is_nil(Learning.get_mistake_for_config!(config.id, mistake.id).learned_at)
    end

    test "does not mutate a mistake from another configuration", %{conn: conn, config: config} do
      {:ok, other_config} = create_config("German Practice", "de")
      {:ok, other_mistake} = create_mistake(other_config.id, "Ich bin gut", "Mir geht es gut")
      {:ok, view, _html} = live(conn, ~p"/review/#{config.id}")
      render_async(view)

      render_hook(view, "mark_learned", %{"id" => Integer.to_string(other_mistake.id)})

      assert render(view) =~ "That review item is unavailable."

      assert is_nil(
               Learning.get_mistake_for_config!(other_config.id, other_mistake.id).learned_at
             )
    end

    test "redirects malformed configuration IDs safely", %{conn: conn} do
      assert {:error, {:live_redirect, %{to: "/dashboard"}}} =
               live(conn, "/review/not-a-number")
    end

    test "redirects missing configurations safely", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/review/999999")

      assert_redirect(view, "/dashboard")
    end
  end

  defp create_config(name, target_language_code) do
    Learning.create_config(%{
      name: name,
      native_language_code: "en",
      target_language_code: target_language_code,
      cefr_level_code: "A2",
      register_code: "informal"
    })
  end

  defp create_mistake(config_id, original_input, corrected_form) do
    Learning.create_mistake(%{
      config_id: config_id,
      original_input: original_input,
      corrected_form: corrected_form,
      explanation: "Use the corrected form in your next conversation."
    })
  end
end
