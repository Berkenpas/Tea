defmodule Tea.Guestbook do
  @moduledoc """
  The visitor guestbook context.
  """

  import Ecto.Query, warn: false

  alias Tea.Accounts.Scope
  alias Tea.Guestbook.Entry
  alias Tea.Repo

  @recent_entry_limit 150

  def count_entries do
    Repo.aggregate(Entry, :count, :id)
  end

  def list_recent_entries do
    Entry
    |> order_by([entry], desc: entry.inserted_at, desc: entry.id)
    |> limit(@recent_entry_limit)
    |> preload(:user)
    |> Repo.all()
    |> Enum.reverse()
  end

  def change_entry(%Entry{} = entry, attrs \\ %{}) do
    Entry.changeset(entry, attrs)
  end

  def create_entry(%Scope{} = scope, attrs) do
    user_id = scope.user && scope.user.id

    attrs =
      attrs
      |> Map.take([
        "display_name",
        :display_name,
        "blurb",
        :blurb,
        "message",
        :message
      ])
      |> normalize_attrs()
      |> maybe_put_user_id(user_id)

    %Entry{}
    |> Entry.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, entry} -> {:ok, Repo.preload(entry, :user)}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def create_entry(nil, attrs), do: create_entry(%Scope{}, attrs)

  defp normalize_attrs(%{display_name: display_name, message: message} = attrs) do
    %{
      "display_name" => display_name,
      "blurb" => Map.get(attrs, :blurb),
      "message" => message
    }
  end

  defp normalize_attrs(%{"display_name" => display_name, "message" => message} = attrs) do
    %{
      "display_name" => display_name,
      "blurb" => Map.get(attrs, "blurb"),
      "message" => message
    }
  end

  defp normalize_attrs(_attrs), do: %{}

  defp maybe_put_user_id(attrs, nil), do: attrs
  defp maybe_put_user_id(attrs, user_id), do: Map.put(attrs, "user_id", user_id)
end
