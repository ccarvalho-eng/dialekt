defmodule DialektWeb.ErrorJSONTest do
  use DialektWeb.ConnCase, async: true

  test "renders 404" do
    assert DialektWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert DialektWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
