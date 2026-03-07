defmodule DialektWeb.SetupLiveTest do
  use DialektWeb.ConnCase

  import Phoenix.LiveViewTest

  describe "SetupLive" do
    test "renders setup screen with brand and steps", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")

      assert html =~ "DIALEKT"
      assert html =~ "I speak"
      assert html =~ "I want to learn"
      assert html =~ "My level"
      assert html =~ "Register"
    end

    test "shows quick native languages", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      # Check for quick language buttons
      assert has_element?(view, "button", "English")
      assert has_element?(view, "button", "Spanish")
      assert has_element?(view, "button", "French")
      assert has_element?(view, "button", "German")
      assert has_element?(view, "button", "Mandarin")
      assert has_element?(view, "button", "Japanese")
    end

    test "disables target language selection until native is selected", %{conn: conn} do
      {:ok, view, html} = live(conn, "/")

      # Initially disabled
      assert html =~ "Select your native language first"

      # Select native language
      view
      |> element("button", "English")
      |> render_click()

      refute render(view) =~ "Select your native language first"
      assert has_element?(view, "[phx-value-step=\"target\"]")
    end

    test "disables level selection until target is selected", %{conn: conn} do
      {:ok, view, html} = live(conn, "/")

      # Initially disabled
      assert html =~ "Select a language to learn first"

      # Select native language
      view
      |> element("button", "English")
      |> render_click()

      # Select target language - need to search for it
      send(view.pid, {:select_target, "es"})

      refute render(view) =~ "Select a language to learn first"
    end

    test "disables register selection until level is selected", %{conn: conn} do
      {:ok, view, html} = live(conn, "/")

      # Initially disabled
      assert html =~ "Select your level first"

      # Select native, target, and level
      view
      |> element("button", "English")
      |> render_click()

      send(view.pid, {:select_target, "es"})
      send(view.pid, {:select_level, "A1"})

      refute render(view) =~ "Select your level first"
    end

    test "enables start button when all selections are made", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      # Initially disabled
      assert has_element?(view, "button[disabled]", "Complete all steps above")

      # Make all selections
      view
      |> element("button", "English")
      |> render_click()

      send(view.pid, {:select_target, "es"})
      send(view.pid, {:select_level, "A1"})
      send(view.pid, {:select_register, "informal"})

      # Start button should be enabled
      assert has_element?(view, "button", "Start Informal Spanish at A1")
    end

    test "can search for languages", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      # Click other button to show search
      view
      |> element("button", "other")
      |> render_click()

      # Should show search input
      assert has_element?(view, "input[placeholder*=\"Search\"]")

      # Type in search
      view
      |> element("input[placeholder*=\"Search\"]")
      |> render_change(%{"search" => "italian"})

      # Should show Italian
      assert has_element?(view, "button", "Italian")
    end

    test "shows CEFR levels", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      # Select native and target language first
      view
      |> element("button", "English")
      |> render_click()

      send(view.pid, {:select_target, "es"})

      # Check all CEFR levels are displayed
      assert has_element?(view, "button", "A1")
      assert has_element?(view, "button", "A2")
      assert has_element?(view, "button", "B1")
      assert has_element?(view, "button", "B2")
      assert has_element?(view, "button", "C1")
      assert has_element?(view, "button", "C2")
    end

    test "shows registers", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      # Select native, target, and level first
      view
      |> element("button", "English")
      |> render_click()

      send(view.pid, {:select_target, "es"})
      send(view.pid, {:select_level, "A1"})

      # Check registers are displayed
      assert has_element?(view, "button", "Informal")
      assert has_element?(view, "button", "Formal")
    end

    test "navigates to chat when start is clicked", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      # Make all selections
      view
      |> element("button", "English")
      |> render_click()

      send(view.pid, {:select_target, "es"})
      send(view.pid, {:select_level, "A1"})
      send(view.pid, {:select_register, "informal"})

      # Click start
      view
      |> element("button", "Start Informal Spanish at A1")
      |> render_click()

      # Should navigate to chat with parameters
      assert_redirect(view, "/chat?native=en&target=es&level=A1&register=informal")
    end
  end
end
