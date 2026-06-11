defmodule TeaWeb.Router do
  use TeaWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {TeaWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
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
end
