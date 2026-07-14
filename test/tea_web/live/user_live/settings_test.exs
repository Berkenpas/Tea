defmodule TeaWeb.UserLive.SettingsTest do
  use TeaWeb.ConnCase

  import Phoenix.LiveViewTest
  import Tea.AccountsFixtures

  describe "Settings page" do
    test "renders settings page", %{conn: conn} do
      {:ok, _lv, html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/users/settings")

      assert html =~ "Account Settings"
      assert html =~ "Your account is managed through Google sign-in."
      assert html =~ "Signed in as"
      refute html =~ "Change Email"
      refute html =~ "Save Password"
    end

    test "redirects if user is not logged in", %{conn: conn} do
      assert {:error, redirect} = live(conn, ~p"/users/settings")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/users/log-in"
      assert %{"error" => "You must log in to access this page."} = flash
    end

    test "does not require sudo mode because no sensitive changes are exposed", %{conn: conn} do
      {:ok, _lv, html} =
        conn
        |> log_in_user(user_fixture(),
          token_authenticated_at: DateTime.add(DateTime.utc_now(:second), -11, :minute)
        )
        |> live(~p"/users/settings")

      assert html =~ "Account Settings"
    end
  end
end
