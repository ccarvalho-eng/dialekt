defmodule DialektWeb.PageController do
  use DialektWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
