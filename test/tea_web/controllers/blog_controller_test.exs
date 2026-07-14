defmodule TeaWeb.BlogControllerTest do
  use TeaWeb.ConnCase

  test "GET /articles redirects to writings", %{conn: conn} do
    conn = get(conn, ~p"/articles")

    assert redirected_to(conn) == ~p"/writings"
  end

  test "GET /articles/:slug redirects to the writing route", %{conn: conn} do
    conn = get(conn, ~p"/articles/first-steep")

    assert redirected_to(conn) == ~p"/writings/first-steep"
  end

  test "GET /writings", %{conn: conn} do
    conn = get(conn, ~p"/writings")

    body = html_response(conn, 200)
    assert body =~ "Writings"
    assert body =~ "Old Reliable: Or, The Beauty of the Simple, and Difficulty of the Luxurious"
  end

  test "GET /reviews", %{conn: conn} do
    conn = get(conn, ~p"/reviews")

    body = html_response(conn, 200)
    assert body =~ "Reviews"
    assert body =~ "2026 Dragon Claw Tea (Ya Bao White Tea)"
  end

  test "GET /writings/:slug", %{conn: conn} do
    conn = get(conn, ~p"/writings/old-reliable")

    body = html_response(conn, 200)
    assert body =~ "Old Reliable: Or, The Beauty of the Simple, and Difficulty of the Luxurious"
    assert body =~ "Back to writings"
  end

  test "GET /reviews/:slug does not show writing posts", %{conn: conn} do
    conn = get(conn, ~p"/reviews/first-steep")

    assert html_response(conn, 404)
  end
end
