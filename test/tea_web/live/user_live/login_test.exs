defmodule TeaWeb.UserLive.LoginTest do
  use TeaWeb.ConnCase

  import Phoenix.LiveViewTest
  import Tea.AccountsFixtures

  describe "login page" do
    test "renders login page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/users/log-in")

      assert html =~ "Log in"
      assert html =~ "Continue with Google"
      refute html =~ "Log in with email"
      refute html =~ "Log in with your password"
    end

    test "links to Google OAuth", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/log-in")

      assert has_element?(lv, "#google-login-link[href='/users/auth/google']")
    end
  end

  describe "re-authentication (sudo mode)" do
    setup %{conn: conn} do
      user = user_fixture()
      %{user: user, conn: log_in_user(conn, user)}
    end

    test "shows Google re-authentication", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/users/log-in")

      assert html =~ "Reauthenticate with Google"
      assert html =~ "Continue with Google"
      refute html =~ ~s(type="email")
    end
  end
end
