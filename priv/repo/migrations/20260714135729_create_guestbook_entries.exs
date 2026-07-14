defmodule Tea.Repo.Migrations.CreateGuestbookEntries do
  use Ecto.Migration

  def change do
    create table(:guestbook_entries) do
      add :display_name, :string, null: false
      add :calling_card, :string
      add :message, :text, null: false
      add :user_id, references(:users, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create index(:guestbook_entries, [:inserted_at])
    create index(:guestbook_entries, [:user_id])
  end
end
