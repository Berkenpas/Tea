defmodule TeaWeb.UserLive.Registration do
  use TeaWeb, :live_view

  require Logger

  alias Tea.Accounts
  alias Tea.Accounts.User

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <main class="site-main site-main--auth">
        <section class="auth-panel">
          <div class="auth-panel__heading">
            <.header>
              Register for an account
              <:subtitle>
                Already registered?
                <.link navigate={~p"/users/log-in"} class="inline-text-link">
                  Log in
                </.link>
                to your account now.
              </:subtitle>
            </.header>
          </div>

          <.form for={@form} id="registration_form" phx-submit="save" phx-change="validate">
            <.link href={~p"/users/auth/google"} class="button button--google">
              <%!-- Google G logo (inline SVG, no external deps) --%>
              <svg viewBox="0 0 24 24" aria-hidden="true">
                <path
                  fill="#4285F4"
                  d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"
                />
                <path
                  fill="#34A853"
                  d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"
                />
                <path
                  fill="#FBBC05"
                  d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l3.66-2.84z"
                />
                <path
                  fill="#EA4335"
                  d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"
                />
              </svg>
              Continue with Google
            </.link>

            <div class="form-divider">or register with email</div>

            <.input
              field={@form[:email]}
              type="email"
              label="Email"
              autocomplete="username"
              spellcheck="false"
              required
              phx-mounted={JS.focus()}
            />

            <.button phx-disable-with="Creating account..." variant="primary">
              Create an account
            </.button>
          </.form>
        </section>
      </main>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, %{assigns: %{current_scope: %{user: user}}} = socket)
      when not is_nil(user) do
    {:ok, redirect(socket, to: TeaWeb.UserAuth.signed_in_path(socket))}
  end

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_email(%User{}, %{}, validate_unique: false)

    {:ok, assign_form(socket, changeset), temporary_assigns: [form: nil]}
  end

  @impl true
  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        case Accounts.deliver_login_instructions(user, &url(~p"/users/log-in/#{&1}")) do
          {:ok, _} ->
            {:noreply,
             socket
             |> put_flash(
               :info,
               "An email was sent to #{user.email}, please access it to confirm your account."
             )
             |> push_navigate(to: ~p"/users/log-in")}

          {:error, reason} ->
            Logger.warning(
              "Failed to deliver registration login instructions for user_id=#{user.id}: #{inspect(reason)}"
            )

            {:noreply,
             socket
             |> put_flash(
               :error,
               "Your account was created, but we could not send your email link right now. Please try logging in again in a moment."
             )
             |> push_navigate(to: ~p"/users/log-in")}
        end

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_email(%User{}, user_params, validate_unique: false)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")
    assign(socket, form: form)
  end
end
