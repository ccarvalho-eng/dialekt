defmodule DialektWeb.DashboardLiveTest do
  use DialektWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Dialekt.Learning

  describe "Dashboard - Empty State" do
    test "shows empty state when no configs exist", %{conn: conn} do
      {:ok, view, html} = live(conn, ~p"/dashboard")

      assert html =~ "Welcome!"
      assert html =~ "Create your first learning configuration"
      assert has_element?(view, "a[href='/']")
    end

    test "empty state links to setup page", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/dashboard")

      # Click the link which triggers navigation
      result = view |> element("a", "Create Your First Config") |> render_click()

      # Should redirect to setup page
      assert {:error, {:live_redirect, %{to: "/"}}} = result
    end
  end

  describe "Dashboard - Config Grid" do
    setup do
      {:ok, config} =
        Learning.create_config(%{
          name: "German Practice",
          native_language_code: "en",
          target_language_code: "de",
          cefr_level_code: "B1",
          register_code: "formal"
        })

      %{config: config}
    end

    test "displays existing configs in grid", %{conn: conn, config: config} do
      {:ok, _view, html} = live(conn, ~p"/dashboard")

      assert html =~ config.name
      assert html =~ "EN"
      assert html =~ "DE"
      assert html =~ "B1"
      assert html =~ "Formal"
    end

    test "shows New Configuration button when configs exist", %{
      conn: conn
    } do
      {:ok, view, html} = live(conn, ~p"/dashboard")

      assert html =~ "+ New Configuration"
      assert has_element?(view, "a[href='/']")
    end

    test "displays session count for each config", %{
      conn: conn,
      config: config
    } do
      # Create some sessions
      {:ok, _session1} = Learning.create_session(config.id)
      {:ok, _session2} = Learning.create_session(config.id)

      {:ok, _view, html} = live(conn, ~p"/dashboard")

      assert html =~ "2 session(s)"
    end

    test "shows zero sessions for new config", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/dashboard")

      assert html =~ "0 session(s)"
    end
  end

  describe "Dashboard - Config Management" do
    setup do
      {:ok, config} =
        Learning.create_config(%{
          name: "Spanish Practice",
          native_language_code: "en",
          target_language_code: "es",
          cefr_level_code: "A2",
          register_code: "informal"
        })

      %{config: config}
    end

    test "creates new chat session and navigates", %{
      conn: conn,
      config: config
    } do
      {:ok, view, _html} = live(conn, ~p"/dashboard")

      # Click "New Chat" button
      view
      |> element("button", "New Chat")
      |> render_click()

      # Should create a session and navigate to chat
      sessions = Learning.list_sessions_for_config(config.id)
      assert length(sessions) == 1

      # Verify navigation happened by checking the redirect path
      session = hd(sessions)
      assert_redirect(view, "/chat?session_id=#{session.id}")
    end

    test "deletes config and refreshes view", %{conn: conn, config: config} do
      {:ok, view, _html} = live(conn, ~p"/dashboard")

      # Verify config exists
      assert render(view) =~ config.name

      # Click delete button to show modal
      view
      |> element("button[phx-value-config-id='#{config.id}']", "Delete")
      |> render_click()

      # Confirm deletion in modal
      view
      |> element("#delete-config-modal-#{config.id} button", "Delete")
      |> render_click()

      # Config should be deleted
      assert_raise Ecto.NoResultsError, fn ->
        Learning.get_config!(config.id)
      end

      # View should show empty state
      assert render(view) =~ "Welcome!"
    end

    test "clicking config name enters edit mode", %{
      conn: conn,
      config: config
    } do
      {:ok, view, _html} = live(conn, ~p"/dashboard")

      # Click on config name to edit
      view
      |> element("h3", config.name)
      |> render_click()

      # Should show input field with current name
      assert has_element?(view, "input[value='#{config.name}']")
    end

    test "editing config name updates database", %{
      conn: conn,
      config: config
    } do
      {:ok, view, _html} = live(conn, ~p"/dashboard")

      # Enter edit mode
      view
      |> element("h3", config.name)
      |> render_click()

      # Update the name
      new_name = "Updated German Practice"

      view
      |> element("input[value='#{config.name}']")
      |> render_change(%{value: new_name})

      # Blur to save
      view
      |> element("input[value='#{new_name}']")
      |> render_blur()

      # Verify in database
      updated_config = Learning.get_config!(config.id)
      assert updated_config.name == new_name

      # Verify in view
      assert render(view) =~ new_name
      refute render(view) =~ config.name
    end

    @tag :skip
    test "pressing Escape cancels edit mode", %{
      conn: conn,
      config: config
    } do
      {:ok, view, _html} = live(conn, ~p"/dashboard")

      # Enter edit mode
      view
      |> element("h3", config.name)
      |> render_click()

      # Change the value
      view
      |> element("input[value='#{config.name}']")
      |> render_change(%{value: "Changed Name"})

      # Press Escape
      # NOTE: Requires phx-window-keydown handler for Escape key
      view
      |> element("input")
      |> render_keydown(%{key: "Escape"})

      # Should exit edit mode and keep original name
      assert render(view) =~ config.name
      refute has_element?(view, "input")
    end
  end

  describe "Dashboard - Multiple Configs" do
    test "displays multiple configs in grid layout", %{conn: conn} do
      # Create multiple configs
      {:ok, config1} =
        Learning.create_config(%{
          name: "German A1",
          native_language_code: "en",
          target_language_code: "de",
          cefr_level_code: "A1",
          register_code: "formal"
        })

      {:ok, config2} =
        Learning.create_config(%{
          name: "French B2",
          native_language_code: "en",
          target_language_code: "fr",
          cefr_level_code: "B2",
          register_code: "informal"
        })

      {:ok, config3} =
        Learning.create_config(%{
          name: "Spanish C1",
          native_language_code: "en",
          target_language_code: "es",
          cefr_level_code: "C1",
          register_code: "formal"
        })

      {:ok, _view, html} = live(conn, ~p"/dashboard")

      # All configs should be visible
      assert html =~ config1.name
      assert html =~ config2.name
      assert html =~ config3.name

      # Should show correct details
      assert html =~ "A1"
      assert html =~ "B2"
      assert html =~ "C1"
    end

    test "each config has independent action buttons", %{conn: conn} do
      {:ok, config1} =
        Learning.create_config(%{
          name: "Config 1",
          native_language_code: "en",
          target_language_code: "de",
          cefr_level_code: "A1",
          register_code: "formal"
        })

      {:ok, config2} =
        Learning.create_config(%{
          name: "Config 2",
          native_language_code: "en",
          target_language_code: "fr",
          cefr_level_code: "B1",
          register_code: "formal"
        })

      {:ok, view, _html} = live(conn, ~p"/dashboard")

      # Click delete button for config1 to show modal
      view
      |> element("button[phx-value-config-id='#{config1.id}']", "Delete")
      |> render_click()

      # Confirm deletion in modal
      view
      |> element("#delete-config-modal-#{config1.id} button", "Delete")
      |> render_click()

      # Config1 should be deleted
      assert_raise Ecto.NoResultsError, fn ->
        Learning.get_config!(config1.id)
      end

      # Config2 should still exist
      assert Learning.get_config!(config2.id)
      assert render(view) =~ "Config 2"
    end
  end
end
