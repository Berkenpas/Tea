defmodule TeaWeb.GoogleAuthController do
  use TeaWeb, :controller

  require Logger

  @google_auth_url "https://accounts.google.com/o/oauth2/v2/auth"
  @google_token_url "https://oauth2.googleapis.com/token"
  @google_userinfo_url "https://www.googleapis.com/oauth2/v3/userinfo"

  @doc """
  Redirects the user to Google's OAuth consent screen.
  Stores a random state token in the session to prevent CSRF.
  """
  def authorize(conn, _params) do
    if google_configured?() do
      state = :crypto.strong_rand_bytes(32) |> Base.url_encode64(padding: false)

      params = %{
        client_id: google_client_id(),
        redirect_uri: callback_url(),
        response_type: "code",
        scope: "openid email",
        state: state,
        access_type: "online",
        prompt: "select_account"
      }

      auth_url = @google_auth_url <> "?" <> URI.encode_query(params)

      conn
      |> put_session(:google_oauth_state, state)
      |> redirect(external: auth_url)
    else
      Logger.error("Google OAuth credentials are not configured")

      conn
      |> put_flash(:error, "Google sign-in is not configured yet.")
      |> redirect(to: ~p"/users/log-in")
    end
  end

  @doc """
  Handles the OAuth callback from Google.
  Exchanges the code for tokens, fetches the user's email, and logs them in.
  """
  def callback(conn, %{"code" => code, "state" => state}) do
    expected_state = get_session(conn, :google_oauth_state)

    if !valid_state?(state, expected_state) do
      Logger.warning("Google OAuth state mismatch — possible CSRF attempt")

      conn
      |> delete_session(:google_oauth_state)
      |> put_flash(:error, "Authentication failed. Please try again.")
      |> redirect(to: ~p"/users/log-in")
    else
      conn
      |> delete_session(:google_oauth_state)
      |> exchange_code_and_login(code)
    end
  end

  def callback(conn, %{"error" => error}) do
    Logger.info("Google OAuth returned error: #{error}")

    conn
    |> delete_session(:google_oauth_state)
    |> put_flash(:error, "Google sign-in was cancelled or denied.")
    |> redirect(to: ~p"/users/log-in")
  end

  def callback(conn, _params) do
    conn
    |> delete_session(:google_oauth_state)
    |> put_flash(:error, "Unexpected response from Google. Please try again.")
    |> redirect(to: ~p"/users/log-in")
  end

  # --- Private ---

  defp exchange_code_and_login(conn, code) do
    with {:ok, access_token} <- exchange_code_for_token(code),
         {:ok, user_info} <- fetch_user_info(access_token),
         :ok <- verify_email(user_info),
         {:ok, user} <- Tea.Accounts.find_or_register_google_user(user_info) do
      TeaWeb.UserAuth.log_in_user(conn, user)
    else
      {:error, :unverified_email} ->
        conn
        |> put_flash(:error, "Your Google account email is not verified.")
        |> redirect(to: ~p"/users/log-in")

      {:error, %Ecto.Changeset{} = changeset} ->
        Logger.error("Google OAuth: failed to find/create user: #{inspect(changeset.errors)}")

        conn
        |> put_flash(:error, "Could not sign you in. Please contact support.")
        |> redirect(to: ~p"/users/log-in")

      {:error, reason} ->
        Logger.error("Google OAuth error: #{inspect(reason)}")

        conn
        |> put_flash(:error, "Google sign-in failed. Please try again.")
        |> redirect(to: ~p"/users/log-in")
    end
  end

  defp exchange_code_for_token(code) do
    body = %{
      code: code,
      client_id: google_client_id(),
      client_secret: google_client_secret(),
      redirect_uri: callback_url(),
      grant_type: "authorization_code"
    }

    case Req.post(@google_token_url, [form: body] ++ google_req_options()) do
      {:ok, %{status: 200, body: %{"access_token" => access_token}}}
      when is_binary(access_token) ->
        {:ok, access_token}

      {:ok, %{status: 200, body: body}} ->
        Logger.error("Google token exchange returned no access token: #{inspect(body)}")
        {:error, :invalid_token_response}

      {:ok, %{status: status, body: body}} ->
        Logger.error("Google token exchange failed (HTTP #{status}): #{inspect(body)}")
        {:error, :token_exchange_failed}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp fetch_user_info(access_token) do
    options =
      [
        headers: [{"authorization", "Bearer #{access_token}"}]
      ] ++ google_req_options()

    case Req.get(@google_userinfo_url, options) do
      {:ok,
       %{
         status: 200,
         body: %{
           "email" => email,
           "sub" => google_uid,
           "email_verified" => email_verified
         }
       }}
      when is_binary(email) and is_binary(google_uid) ->
        {:ok,
         %{
           email: email,
           google_uid: google_uid,
           email_verified: email_verified
         }}

      {:ok, %{status: 200, body: body}} ->
        Logger.error("Google userinfo response was incomplete: #{inspect(body)}")
        {:error, :invalid_userinfo}

      {:ok, %{status: status, body: body}} ->
        Logger.error("Google userinfo failed (HTTP #{status}): #{inspect(body)}")
        {:error, :userinfo_failed}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp verify_email(%{email_verified: true}), do: :ok
  defp verify_email(_), do: {:error, :unverified_email}

  defp valid_state?(state, expected_state)
       when is_binary(state) and is_binary(expected_state) and
              byte_size(state) == byte_size(expected_state) do
    Plug.Crypto.secure_compare(state, expected_state)
  end

  defp valid_state?(_state, _expected_state), do: false

  defp callback_url do
    url(~p"/users/auth/google/callback")
  end

  defp google_client_id do
    Application.fetch_env!(:tea, :google_client_id)
  end

  defp google_client_secret do
    Application.fetch_env!(:tea, :google_client_secret)
  end

  defp google_configured? do
    google_client_id() != "" and google_client_secret() != ""
  end

  defp google_req_options do
    Application.get_env(:tea, :google_req_options, [])
  end
end
