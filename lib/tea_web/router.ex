defmodule TeaWeb.Router do
  use TeaWeb, :router

  import TeaWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {TeaWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TeaWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/articles", BlogController, :articles
    get "/articles/:slug", BlogController, :article
    get "/writings", BlogController, :writings
    get "/writings/:slug", BlogController, :writing
    get "/reviews", BlogController, :reviews
    get "/reviews/:slug", BlogController, :review
  end

  # Other scopes may use custom stacks.
  # scope "/api", TeaWeb do
  #   pipe_through :api
  # end

  ## Authentication routes

  scope "/", TeaWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{TeaWeb.UserAuth, :require_authenticated}] do
      live "/chat", ChatLive, :show
      live "/users/settings", UserLive.Settings, :edit
    end
  end

  scope "/", TeaWeb do
    pipe_through [:browser]

    live_session :current_user,
      on_mount: [{TeaWeb.UserAuth, :mount_current_scope}] do
      live "/users/register", UserLive.Registration, :new
      live "/users/log-in", UserLive.Login, :new
    end

    delete "/users/log-out", UserSessionController, :delete
  end

  scope "/users/auth", TeaWeb do
    pipe_through :browser

    get "/google", GoogleAuthController, :authorize
    get "/google/callback", GoogleAuthController, :callback
  end
end
