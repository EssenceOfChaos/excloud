defmodule ExcloudWeb.PageController do
  use ExcloudWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
