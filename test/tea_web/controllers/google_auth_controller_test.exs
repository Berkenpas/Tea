defmodule TeaWeb.GoogleAuthControllerTest do
  use TeaWeb.ConnCase

  alias Tea.Accounts

  describe "GET /users/auth/google" do
    test "redirects to Google with a state stored in the session", %{conn: conn} do
      conn = get(conn, ~p"/users/auth/google")

      location = get_resp_header(conn, "location") |> List.first() |> URI.parse()
      params = URI.decode_query(location.query)

      assert conn.status == 302
      assert location.host == "accounts.google.com"
      assert params["client_id"] == "google-client-id"
      assert URI.parse(params["redirect_uri"]).path == "/users/auth/google/callback"
      assert params["scope"] == "openid email"
      assert params["state"] == get_session(conn, :google_oauth_state)
    end
  end

  describe "GET /users/auth/google/callback" do
    test "creates and logs in a user with a verified Google email", %{conn: conn} do
      expect_successful_google_requests("new-user@example.com", "google-uid-1", true)

      conn =
        conn
        |> init_test_session(google_oauth_state: "valid-state")
        |> get(~p"/users/auth/google/callback?code=valid-code&state=valid-state")

      user = Accounts.get_user_by_email("new-user@example.com")

      assert user.google_uid == "google-uid-1"
      assert user.confirmed_at
      assert get_session(conn, :user_token)
      assert redirected_to(conn) == ~p"/"
      refute get_session(conn, :google_oauth_state)
    end

    test "links Google to an existing email account", %{conn: conn} do
      existing_user = Tea.AccountsFixtures.unconfirmed_user_fixture(%{email: "same@example.com"})
      expect_successful_google_requests(existing_user.email, "google-uid-2", true)

      conn =
        conn
        |> init_test_session(google_oauth_state: "valid-state")
        |> get(~p"/users/auth/google/callback?code=valid-code&state=valid-state")

      linked_user = Accounts.get_user!(existing_user.id)

      assert linked_user.google_uid == "google-uid-2"
      assert linked_user.confirmed_at
      assert get_session(conn, :user_token)
    end

    test "rejects an invalid state before making HTTP requests", %{conn: conn} do
      conn =
        conn
        |> init_test_session(google_oauth_state: "expected-state")
        |> get(~p"/users/auth/google/callback?code=valid-code&state=wrong-state")

      assert redirected_to(conn) == ~p"/users/log-in"
      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~ "Authentication failed"
      refute get_session(conn, :google_oauth_state)
    end

    test "rejects a Google account whose email is not verified", %{conn: conn} do
      expect_successful_google_requests("unverified@example.com", "google-uid-3", false)

      conn =
        conn
        |> init_test_session(google_oauth_state: "valid-state")
        |> get(~p"/users/auth/google/callback?code=valid-code&state=valid-state")

      assert redirected_to(conn) == ~p"/users/log-in"
      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~ "email is not verified"
      refute Accounts.get_user_by_email("unverified@example.com")
    end

    test "handles a failed token exchange", %{conn: conn} do
      Req.Test.expect(TeaWeb.GoogleAuthController, fn conn ->
        conn
        |> Plug.Conn.put_status(401)
        |> Req.Test.json(%{"error" => "invalid_grant"})
      end)

      conn =
        conn
        |> init_test_session(google_oauth_state: "valid-state")
        |> get(~p"/users/auth/google/callback?code=bad-code&state=valid-state")

      assert redirected_to(conn) == ~p"/users/log-in"
      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~ "Google sign-in failed"
    end
  end

  defp expect_successful_google_requests(email, google_uid, email_verified) do
    Req.Test.expect(TeaWeb.GoogleAuthController, 2, fn conn ->
      case conn.request_path do
        "/token" ->
          Req.Test.json(conn, %{"access_token" => "access-token"})

        "/oauth2/v3/userinfo" ->
          assert Plug.Conn.get_req_header(conn, "authorization") == ["Bearer access-token"]

          Req.Test.json(conn, %{
            "email" => email,
            "sub" => google_uid,
            "email_verified" => email_verified
          })
      end
    end)
  end
end
