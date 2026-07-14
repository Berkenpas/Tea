defmodule Tea.Guestbook.Entry do
  use Ecto.Schema
  import Ecto.Changeset

  schema "guestbook_entries" do
    field(:display_name, :string)
    field(:blurb, :string)
    field(:message, :string)

    belongs_to(:user, Tea.Accounts.User)

    timestamps(type: :utc_datetime)
  end

  def changeset(entry, attrs) do
    entry
    |> cast(attrs, [:display_name, :blurb, :message, :user_id])
    |> validate_required([:display_name, :message])
    |> validate_length(:display_name, min: 1, max: 80)
    |> validate_length(:blurb, max: 120)
    |> validate_length(:message, min: 1, max: 400)
    |> foreign_key_constraint(:user_id)
  end
end
