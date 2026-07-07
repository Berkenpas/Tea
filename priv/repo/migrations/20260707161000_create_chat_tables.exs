defmodule Tea.Repo.Migrations.CreateChatTables do
  use Ecto.Migration

  def change do
    create table(:chat_rooms) do
      add :name, :string, null: false
      add :slug, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:chat_rooms, [:slug])

    create table(:chat_messages) do
      add :body, :text, null: false
      add :room_id, references(:chat_rooms, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:chat_messages, [:room_id, :inserted_at])
    create index(:chat_messages, [:user_id])
  end
end
