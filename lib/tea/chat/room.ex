defmodule Tea.Chat.Room do
  use Ecto.Schema
  import Ecto.Changeset

  schema "chat_rooms" do
    field(:name, :string)
    field(:slug, :string)

    has_many(:messages, Tea.Chat.Message)

    timestamps(type: :utc_datetime)
  end

  def changeset(room, attrs) do
    room
    |> cast(attrs, [:name, :slug])
    |> validate_required([:name, :slug])
    |> validate_length(:name, max: 80)
    |> validate_length(:slug, max: 80)
    |> validate_format(:slug, ~r/^[a-z0-9]+(?:-[a-z0-9]+)*$/,
      message: "must use lowercase letters, numbers, and hyphens"
    )
    |> unique_constraint(:slug)
  end
end
