defmodule Tea.Chat.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "chat_messages" do
    field(:body, :string)

    belongs_to(:room, Tea.Chat.Room)
    belongs_to(:user, Tea.Accounts.User)

    timestamps(type: :utc_datetime)
  end

  def changeset(message, attrs) do
    message
    |> cast(attrs, [:body, :room_id, :user_id])
    |> validate_required([:body, :room_id, :user_id])
    |> validate_length(:body, min: 1, max: 1_000)
    |> foreign_key_constraint(:room_id)
    |> foreign_key_constraint(:user_id)
  end
end
