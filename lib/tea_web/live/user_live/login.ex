defmodule TeaWeb.UserLive.Login do
  use TeaWeb, :live_view

  alias Tea.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <main class="site-main site-main--auth">
        <section class="auth-panel">
          <div class="auth-panel__heading">
            <.header>
              <p>Log in</p>
              <:subtitle>
                <%= if @current_scope do %>
                  You need to reauthenticate to perform sensitive actions on your account.
                <% else %>
                  Don't have an account? <.link
                    navigate={~p"/users/register"}
                    class="inline-text-link"
                    phx-no-format
                  >Sign up</.link> for an account now.
                <% end %>
              </:subtitle>
            </.header>
          </div>

          <div :if={local_mail_adapter?()} class="auth-note">
            <.icon name="hero-information-circle" class="auth-note__icon" />
            <div>
              <p>You are running the local mail adapter.</p>
              <p>
                To see sent emails, visit <.link href="/dev/mailbox" class="inline-text-link">the mailbox page</.link>.
              </p>
            </div>
          </div>

          <.form
            :let={f}
            for={@form}
            id="login_form_magic"
            action={~p"/users/log-in"}
            phx-submit="submit_magic"
          >
            <.input
              readonly={!!@current_scope}
              field={f[:email]}
              type="email"
              label="Email"
              autocomplete="username"
              spellcheck="false"
              required
              phx-mounted={JS.focus()}
            />
            <.button variant="primary">
              Log in with email <span aria-hidden="true">→</span>
            </.button>
          </.form>

          <div class="form-divider">or</div>

          <.form
            :let={f}
            for={@form}
            id="login_form_password"
            action={~p"/users/log-in"}
            phx-submit="submit_password"
            phx-trigger-action={@trigger_submit}
          >
            <.input
              readonly={!!@current_scope}
              field={f[:email]}
              type="email"
              label="Email"
              autocomplete="username"
              spellcheck="false"
              required
            />
            <.input
              field={@form[:password]}
              type="password"
              label="Password"
              autocomplete="current-password"
              spellcheck="false"
            />
            <.button variant="primary" name={@form[:remember_me].name} value="true">
              Log in and stay logged in <span aria-hidden="true">→</span>
            </.button>
            <.button>
              Log in only this time
            </.button>
          </.form>
        </section>
      </main>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    email =
      Phoenix.Flash.get(socket.assigns.flash, :email) ||
        get_in(socket.assigns, [:current_scope, Access.key(:user), Access.key(:email)])

    form = to_form(%{"email" => email}, as: "user")

    {:ok, assign(socket, form: form, trigger_submit: false)}
  end

  @impl true
  def handle_event("submit_password", _params, socket) do
    {:noreply, assign(socket, :trigger_submit, true)}
  end

  def handle_event("submit_magic", %{"user" => %{"email" => email}}, socket) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_login_instructions(
        user,
        &url(~p"/users/log-in/#{&1}")
      )
    end

    info =
      "If your email is in our system, you will receive instructions for logging in shortly."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> push_navigate(to: ~p"/users/log-in")}
  end

  defp local_mail_adapter? do
    Application.get_env(:tea, Tea.Mailer)[:adapter] == Swoosh.Adapters.Local
  end
end
