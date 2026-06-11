defmodule TeaWeb.BlogControllerTest do
  use TeaWeb.ConnCase

  test "GET /articles", %{conn: conn} do
    conn = get(conn, ~p"/articles")

    body = html_response(conn, 200)
    assert body =~ "Brew Log"
    assert body =~ "First Steep"
  end

  test "GET /articles/:slug", %{conn: conn} do
    conn = get(conn, ~p"/articles/first-steep")

    body = html_response(conn, 200)
    assert body =~ "Owner Guide: Running and Growing Your Tea Blog"
    assert body =~ "Back to articles"
  end
end
