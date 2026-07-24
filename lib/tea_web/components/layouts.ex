defmodule TeaWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use TeaWeb, :html

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"

  @doc """
  Renders your app layout.

  This function is typically invoked from every template,
  and it often contains your application menu, sidebar,
  or similar.

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layouts.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <header class="site-header">
      <a href={~p"/"} class="site-mark" aria-label="Berkenpas home">
        <img src={~p"/images/BerkenpasLogo.svg"} alt="" class="site-mark__logo" />
        <span>Berkenpas</span>
      </a>

      <nav class="site-nav" aria-label="Main navigation">
        <div class="site-nav__primary">
          <a id="main-nav-home" href={~p"/"}>Home</a>

          <div id="writings-nav" class="site-nav__dropdown">
            <button type="button" class="site-nav__dropdown-trigger" aria-haspopup="true">
              Writings <.icon name="hero-chevron-down" class="site-nav__dropdown-icon" />
            </button>

            <div class="site-nav__dropdown-menu" role="menu" aria-label="Writings links">
              <a href={~p"/writings"} role="menuitem">Articles</a>
              <a href={~p"/reviews"} role="menuitem">Reviews</a>
            </div>
          </div>

          <div id="community-nav" class="site-nav__dropdown">
            <button type="button" class="site-nav__dropdown-trigger" aria-haspopup="true">
              Community <.icon name="hero-chevron-down" class="site-nav__dropdown-icon" />
            </button>

            <div class="site-nav__dropdown-menu" role="menu" aria-label="Community links">
              <a href={~p"/chat"} role="menuitem">Chat</a>
              <a href={~p"/guestbook"} role="menuitem">Guest Book</a>
            </div>
          </div>
        </div>

        <div class="site-nav__account">
          <a :if={@current_scope && @current_scope.user} href={~p"/users/settings"}>Settings</a>
          <.link :if={@current_scope && @current_scope.user} href={~p"/users/log-out"} method="delete">
            Log out
          </.link>
          <a :if={!(@current_scope && @current_scope.user)} href={~p"/users/log-in"}>Login</a>
          <a :if={!(@current_scope && @current_scope.user)} href={~p"/users/register"}>Register</a>
        </div>
      </nav>
    </header>

    {render_slot(@inner_block)}

    <footer class="site-footer">
      <p>Blog. Blog. Glob. Blog. Blog. Berkenpas. Blog. Blog. Glob</p>
      <a href={~p"/writings"}>Browse the archive</a>
    </footer>

    <.flash_group flash={@flash} />
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title="We can't find the internet"
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        Attempting to reconnect
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title="Something went wrong!"
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        Attempting to reconnect
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end
end
