defmodule Tea.GuestbookTest do
  use Tea.DataCase

  alias Tea.Guestbook
  alias Tea.Guestbook.Entry

  import Tea.AccountsFixtures

  describe "entries" do
    test "create_entry/2 stores an anonymous entry" do
      assert {:ok, %Entry{} = entry} =
               Guestbook.create_entry(nil, %{
                 "display_name" => "River",
                 "blurb" => "tea lover",
                 "message" => "Thank you for the writings"
               })

      assert entry.display_name == "River"
      assert entry.blurb == "tea lover"
      assert entry.message == "Thank you for the writings"
      assert is_nil(entry.user_id)
    end

    test "create_entry/2 stores a signed-in entry" do
      user = user_fixture()
      scope = Tea.Accounts.Scope.for_user(user)

      assert {:ok, %Entry{} = entry} =
               Guestbook.create_entry(scope, %{
                 "display_name" => user.email,
                 "blurb" => "reader",
                 "message" => "Lovely quiet place"
               })

      assert entry.user_id == user.id
      assert entry.user.email == user.email
    end

    test "create_entry/2 validates required fields" do
      assert {:error, changeset} =
               Guestbook.create_entry(nil, %{"display_name" => "", "message" => ""})

      assert %{display_name: ["can't be blank"], message: ["can't be blank"]} =
               errors_on(changeset)
    end

    test "list_recent_entries/0 returns oldest first" do
      {:ok, first} =
        Guestbook.create_entry(nil, %{
          "display_name" => "First",
          "blurb" => "A",
          "message" => "One"
        })

      {:ok, second} =
        Guestbook.create_entry(nil, %{
          "display_name" => "Second",
          "blurb" => "B",
          "message" => "Two"
        })

      assert [%Entry{id: first_id}, %Entry{id: second_id}] = Guestbook.list_recent_entries()
      assert first_id == first.id
      assert second_id == second.id
    end

    test "count_entries/0 returns total entry count" do
      Guestbook.create_entry(nil, %{
        "display_name" => "Counter One",
        "blurb" => "A",
        "message" => "One"
      })

      Guestbook.create_entry(nil, %{
        "display_name" => "Counter Two",
        "blurb" => "B",
        "message" => "Two"
      })

      assert Guestbook.count_entries() == 2
    end
  end
end
