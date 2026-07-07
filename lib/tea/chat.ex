defmodule Tea.Chat do
  @moduledoc """
  The small community chat context.
  """

  import Ecto.Query, warn: false

  alias Tea.Accounts.Scope
  alias Tea.Chat.{Message, Room}
  alias Tea.Repo

  @general_room_attrs %{name: "General", slug: "general"}
  @recent_message_limit 100

  def list_rooms do
    Room
    |> order_by([room], asc: room.name)
    |> Repo.all()
  end

  def get_room_by_slug!(slug) when is_binary(slug) do
    Repo.get_by!(Room, slug: slug)
  end

  def get_or_create_general_room! do
    case Repo.get_by(Room, slug: @general_room_attrs.slug) do
      %Room{} = room ->
        room

      nil ->
        %Room{}
        |> Room.changeset(@general_room_attrs)
        |> Repo.insert!(
          on_conflict: :nothing,
          conflict_target: :slug
        )

        get_room_by_slug!(@general_room_attrs.slug)
    end
  end

  def list_recent_messages(%Room{} = room) do
    Message
    |> where([message], message.room_id == ^room.id)
    |> order_by([message], desc: message.inserted_at, desc: message.id)
    |> limit(@recent_message_limit)
    |> preload(:user)
    |> Repo.all()
    |> Enum.reverse()
  end

  def change_message(%Message{} = message, attrs \\ %{}) do
    Message.changeset(message, attrs)
  end

  def create_message(%Scope{user: user}, %Room{} = room, attrs) when not is_nil(user) do
    attrs =
      attrs
      |> Map.take(["body", :body])
      |> normalize_message_attrs()
      |> Map.put("room_id", room.id)
      |> Map.put("user_id", user.id)

    %Message{}
    |> Message.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, message} ->
        message = Repo.preload(message, :user)
        broadcast_message(room, message)
        {:ok, message}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def subscribe_to_room(%Room{} = room) do
    Phoenix.PubSub.subscribe(Tea.PubSub, topic(room))
  end

  defp broadcast_message(room, message) do
    Phoenix.PubSub.broadcast(Tea.PubSub, topic(room), {:chat_message_created, message})
  end

  defp normalize_message_attrs(%{body: body}), do: %{"body" => body}
  defp normalize_message_attrs(%{"body" => body}), do: %{"body" => body}
  defp normalize_message_attrs(_attrs), do: %{}

  defp topic(room), do: "chat:rooms:#{room.id}"
end
