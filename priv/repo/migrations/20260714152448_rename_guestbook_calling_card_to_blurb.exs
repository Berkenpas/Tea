defmodule Tea.Repo.Migrations.RenameGuestbookCallingCardToBlurb do
  use Ecto.Migration

  def change do
    rename table(:guestbook_entries), :calling_card, to: :blurb
  end
end
