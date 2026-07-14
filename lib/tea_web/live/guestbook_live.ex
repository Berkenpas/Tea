defmodule TeaWeb.GuestbookLive do
  use TeaWeb, :live_view

  alias Tea.Guestbook
  alias Tea.Guestbook.Entry

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:show_form, false)
     |> assign(:entry_form, entry_form(socket.assigns.current_scope))
     |> stream(:entries, Guestbook.list_recent_entries())}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <main class="site-main site-main--guestbook">
        <section class="guestbook-shell">
          <header class="guestbook-header">
            <div>
              <p class="kicker">Community Guest Book</p>
              <h1>Guest Book</h1>
            </div>

            <p :if={@current_scope && @current_scope.user}>
              Leave a name, a short blurb, and a note for future visitors.
            </p>
            <p :if={!(@current_scope && @current_scope.user)}>
              Sign as a visitor with your name, a short blurb, and a short message.
            </p>
          </header>

          <div class="guestbook-actions">
            <.button id="guestbook-sign-toggle" phx-click="toggle_form">
              <%= if @show_form do %>
                Hide form
              <% else %>
                Sign Here!
              <% end %>
            </.button>
          </div>

          <.form
            :if={@show_form}
            for={@entry_form}
            id="guestbook-entry-form"
            class="guestbook-composer"
            phx-submit="sign"
          >
            <div class="guestbook-grid guestbook-grid--compact">
              <.input
                field={@entry_form[:display_name]}
                type="text"
                label="Name"
                maxlength="80"
                required
              />

              <.input
                field={@entry_form[:blurb]}
                type="text"
                label="Blurb"
                maxlength="120"
              />
            </div>

            <.input
              field={@entry_form[:message]}
              type="textarea"
              label="Message"
              rows="3"
              maxlength="400"
              required
            />

            <.button variant="primary" phx-disable-with="Signing...">
              Sign guest book
            </.button>
          </.form>

          <div id="guestbook-entries" class="guestbook-entries" phx-update="stream">
            <div id="guestbook-empty" class="guestbook-empty hidden only:block">
              <p class="kicker">No signatures yet</p>
              <p>Be the first to leave a quiet hello.</p>
            </div>

            <article :for={{id, entry} <- @streams.entries} id={id} class="guestbook-entry">
              <div class="guestbook-entry__meta">
                <span class="guestbook-entry__author">
                  <span>{entry.display_name}</span>
                  <span :if={entry.user_id} class="guestbook-entry__badge">member</span>
                  <span :if={present?(entry.blurb)} class="guestbook-entry__card">
                    ({entry.blurb})
                  </span>
                </span>

                <time datetime={DateTime.to_iso8601(entry.inserted_at)}>
                  {Calendar.strftime(entry.inserted_at, "%b %d, %I:%M %p")}
                </time>
              </div>

              <p>{entry.message}</p>
            </article>
          </div>
        </section>
      </main>
    </Layouts.app>
    """
  end

  @impl true
  def handle_event("toggle_form", _params, socket) do
    {:noreply, update(socket, :show_form, &(!&1))}
  end

  @impl true
  def handle_event("sign", %{"entry" => entry_params}, socket) do
    case Guestbook.create_entry(socket.assigns.current_scope, entry_params) do
      {:ok, entry} ->
        {:noreply,
         socket
         |> assign(:show_form, false)
         |> assign(:entry_form, entry_form(socket.assigns.current_scope))
         |> stream_insert(:entries, entry)}

      {:error, changeset} ->
        {:noreply,
         socket
         |> assign(:show_form, true)
         |> assign(:entry_form, to_form(changeset, as: :entry))}
    end
  end

  defp entry_form(_current_scope) do
    attrs = %{
      "display_name" => "",
      "blurb" => "",
      "message" => ""
    }

    to_form(Guestbook.change_entry(%Entry{}, attrs), as: :entry)
  end

  defp present?(value), do: is_binary(value) && String.trim(value) != ""
end
