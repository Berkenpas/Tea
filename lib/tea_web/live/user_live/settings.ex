defmodule TeaWeb.UserLive.Settings do
  use TeaWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <main class="site-main site-main--auth">
        <section class="auth-panel auth-panel--wide">
          <div class="auth-panel__heading">
            <.header>
              Account Settings
              <:subtitle>Your account is managed through Google sign-in.</:subtitle>
            </.header>
          </div>

          <div class="auth-account-card" id="account-identity">
            <span class="auth-account-card__label">Signed in as</span>
            <span class="auth-account-card__email">{@current_scope.user.email}</span>
          </div>

          <div class="auth-note auth-note--quiet">
            <.icon name="hero-information-circle" class="auth-note__icon" />
            <div>
              <p>Email and password changes are not available here.</p>
              <p>Use your Google account to manage the identity you sign in with.</p>
            </div>
          </div>
        </section>
      </main>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
