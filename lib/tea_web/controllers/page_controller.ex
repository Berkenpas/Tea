defmodule TeaWeb.PageController do
  use TeaWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
