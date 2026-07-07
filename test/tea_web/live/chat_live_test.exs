defmodule TeaWeb.ChatLiveTest do
  use TeaWeb.ConnCase

  import Phoenix.LiveViewTest
  import Tea.AccountsFixtures

  alias Tea.Chat

  test "redirects guests to login", %{conn: conn} do
    assert {:error, {:redirect, %{to: "/users/log-in"}}} = live(conn, ~p"/chat")
  end

  test "renders the general chat room for a logged-in user", %{conn: conn} do
    conn = log_in_user(conn, user_fixture())

    {:ok, _view, html} = live(conn, ~p"/chat")

    assert html =~ "Community Chat"
    assert html =~ "General"
    assert html =~ "Signed in as"
  end

  test "sends a message", %{conn: conn} do
    conn = log_in_user(conn, user_fixture())
    {:ok, view, _html} = live(conn, ~p"/chat")

    view
    |> form("#chat-message-form", message: %{body: "a small hello"})
    |> render_submit()

    assert render(view) =~ "a small hello"

    assert [%{body: "a small hello"}] =
             Chat.list_recent_messages(Chat.get_or_create_general_room!())
  end
end
