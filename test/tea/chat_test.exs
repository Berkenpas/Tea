defmodule Tea.ChatTest do
  use Tea.DataCase

  alias Tea.Chat
  alias Tea.Chat.{Message, Room}

  import Tea.AccountsFixtures

  describe "rooms" do
    test "get_or_create_general_room!/0 creates the default room once" do
      assert %Room{name: "General", slug: "general"} = Chat.get_or_create_general_room!()
      assert %Room{name: "General", slug: "general"} = Chat.get_or_create_general_room!()
      assert [%Room{slug: "general"}] = Chat.list_rooms()
    end
  end

  describe "messages" do
    setup do
      user = user_fixture()
      room = Chat.get_or_create_general_room!()
      scope = Tea.Accounts.Scope.for_user(user)

      %{room: room, scope: scope, user: user}
    end

    test "create_message/3 stores a message for a room and user", %{
      room: room,
      scope: scope,
      user: user
    } do
      assert {:ok, %Message{} = message} = Chat.create_message(scope, room, %{"body" => "hello"})
      assert message.body == "hello"
      assert message.room_id == room.id
      assert message.user_id == user.id
      assert message.user.email == user.email
    end

    test "create_message/3 validates body", %{room: room, scope: scope} do
      assert {:error, changeset} = Chat.create_message(scope, room, %{"body" => ""})
      assert %{body: ["can't be blank"]} = errors_on(changeset)
    end

    test "list_recent_messages/1 returns messages oldest first", %{room: room, scope: scope} do
      {:ok, first} = Chat.create_message(scope, room, %{"body" => "first"})
      {:ok, second} = Chat.create_message(scope, room, %{"body" => "second"})

      assert [%Message{id: first_id}, %Message{id: second_id}] = Chat.list_recent_messages(room)
      assert first_id == first.id
      assert second_id == second.id
    end

    test "create_message/3 broadcasts new messages", %{room: room, scope: scope} do
      Chat.subscribe_to_room(room)

      assert {:ok, message} = Chat.create_message(scope, room, %{"body" => "over the wire"})
      assert_receive {:chat_message_created, %Message{id: message_id}}
      assert message_id == message.id
    end
  end
end
