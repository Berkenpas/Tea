defmodule TeaWeb.PageControllerTest do
  use TeaWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")

    body = html_response(conn, 200)
    assert body =~ "Quiet ideas brewed slowly"
    assert body =~ "Recent post"
  end
end
