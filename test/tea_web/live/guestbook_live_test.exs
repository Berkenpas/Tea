defmodule TeaWeb.GuestbookLiveTest do
  use TeaWeb.ConnCase

  import Phoenix.LiveViewTest
  import Tea.AccountsFixtures

  alias Tea.Guestbook

  test "renders for guests", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/guestbook")

    assert html =~ "Guest Book"
    assert html =~ "Sign as a visitor"
  end

  test "renders for signed-in members", %{conn: conn} do
    conn = log_in_user(conn, user_fixture())

    {:ok, _view, html} = live(conn, ~p"/guestbook")

    assert html =~ "Guest Book"
    assert html =~ "Leave a name"
  end

  test "guest can sign the guest book", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/guestbook")

    refute has_element?(view, "#guestbook-entry-form")

    view
    |> element("#guestbook-sign-toggle")
    |> render_click()

    assert has_element?(view, "#guestbook-entry-form")

    view
    |> form("#guestbook-entry-form",
      entry: %{
        display_name: "Silent Reader",
        blurb: "from Seattle",
        message: "Big fan of the archive"
      }
    )
    |> render_submit()

    assert render(view) =~ "Silent Reader"
    assert render(view) =~ "Big fan of the archive"

    assert [%{display_name: "Silent Reader", user_id: nil}] = Guestbook.list_recent_entries()
  end

  test "member can sign and entry is linked to account", %{conn: conn} do
    user = user_fixture()
    conn = log_in_user(conn, user)
    {:ok, view, _html} = live(conn, ~p"/guestbook")

    view
    |> element("#guestbook-sign-toggle")
    |> render_click()

    view
    |> form("#guestbook-entry-form",
      entry: %{
        display_name: user.email,
        blurb: "member",
        message: "Happy to be here"
      }
    )
    |> render_submit()

    assert render(view) =~ "member"
    assert render(view) =~ "Happy to be here"

    assert [%{display_name: display_name, user_id: user_id}] = Guestbook.list_recent_entries()
    assert display_name == user.email
    assert user_id == user.id
  end

  test "renders Sign Here toggle and no visible form by default", %{conn: conn} do
    {:ok, _entry} =
      Guestbook.create_entry(nil, %{
        "display_name" => "Badge Tester",
        "blurb" => "observer",
        "message" => "Count me in"
      })

    {:ok, view, html} = live(conn, ~p"/guestbook")

    assert html =~ "Sign Here!"
    refute has_element?(view, "#guestbook-entry-form")
  end
end
