defmodule TeaWeb.PageControllerTest do
  use TeaWeb.ConnCase

  import Tea.AccountsFixtures

  alias Tea.Guestbook

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")

    body = html_response(conn, 200)
    assert body =~ "Quiet ideas brewed slowly"
    assert body =~ "Recent post"
    assert body =~ ~s(href="/writings")
    assert body =~ ~s(href="/reviews")
    assert body =~ ~s(href="/guestbook")
    assert body =~ ~s(href="/chat")
    assert body =~ ~s(href="/users/log-in")
    assert body =~ ~s(href="/users/register")
  end

  test "GET / shows guestbook entry count badge on home page", %{conn: conn} do
    Guestbook.create_entry(nil, %{
      "display_name" => "Home Counter",
      "blurb" => "watching",
      "message" => "Counting from home"
    })

    conn = get(conn, ~p"/")

    body = html_response(conn, 200)
    assert body =~ "Guest Book"
    assert body =~ "count-badge"
  end

  test "GET / shows settings instead of login links for signed-in users", %{conn: conn} do
    user = user_fixture()

    conn =
      conn
      |> log_in_user(user)
      |> get(~p"/")

    body = html_response(conn, 200)
    assert body =~ "Signed in as #{user.email}"
    assert body =~ ~s(href="/chat")
    assert body =~ ~s(href="/users/settings")
    assert body =~ ~s(href="/users/log-out")
    refute body =~ ~s(href="/users/log-in")
    refute body =~ ~s(href="/users/register")
  end
end
