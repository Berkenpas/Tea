defmodule TeaWeb.ChatLive do
  use TeaWeb, :live_view

  alias Tea.Chat
  alias Tea.Chat.Message

  @impl true
  def mount(_params, _session, socket) do
    room = Chat.get_or_create_general_room!()
    messages = Chat.list_recent_messages(room)

    if connected?(socket) do
      Chat.subscribe_to_room(room)
    end

    {:ok,
     socket
     |> assign(:room, room)
     |> assign(:message_form, to_form(Chat.change_message(%Message{}), as: :message))
     |> stream(:messages, messages)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <main class="site-main site-main--chat">
        <section class="chat-shell">
          <header class="chat-header">
            <div>
              <p class="kicker">Community Chat</p>
              <h1>{@room.name}</h1>
            </div>

            <p>Signed in as {@current_scope.user.email}</p>
          </header>

          <div id="chat-messages" class="chat-messages" phx-update="stream">
            <div id="chat-empty" class="chat-empty hidden only:block">
              <p class="kicker">No messages yet</p>
              <p>Start the room with a quiet hello.</p>
            </div>

            <article
              :for={{id, message} <- @streams.messages}
              id={id}
              class="chat-message"
            >
              <div class="chat-message__meta">
                <span>{message.user.email}</span>
                <time datetime={DateTime.to_iso8601(message.inserted_at)}>
                  {Calendar.strftime(message.inserted_at, "%b %d, %I:%M %p")}
                </time>
              </div>

              <p>{message.body}</p>
            </article>
          </div>

          <.form
            for={@message_form}
            id="chat-message-form"
            class="chat-composer"
            phx-submit="send_message"
          >
            <.input
              field={@message_form[:body]}
              type="textarea"
              label="Message"
              rows="3"
              maxlength="1000"
              required
            />

            <.button variant="primary" phx-disable-with="Sending...">
              Send message
            </.button>
          </.form>
        </section>
      </main>
    </Layouts.app>
    """
  end

  @impl true
  def handle_event("send_message", %{"message" => message_params}, socket) do
    case Chat.create_message(socket.assigns.current_scope, socket.assigns.room, message_params) do
      {:ok, _message} ->
        {:noreply,
         assign(socket, :message_form, to_form(Chat.change_message(%Message{}), as: :message))}

      {:error, changeset} ->
        {:noreply, assign(socket, :message_form, to_form(changeset, as: :message))}
    end
  end

  @impl true
  def handle_info({:chat_message_created, %Message{} = message}, socket) do
    {:noreply, stream_insert(socket, :messages, message)}
  end
end
