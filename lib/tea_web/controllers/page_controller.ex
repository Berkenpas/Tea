defmodule TeaWeb.PageController do
  use TeaWeb, :controller

  alias Tea.Blog

  def home(conn, _params) do
    recent_article = Blog.list_articles() |> List.first()

    render(conn, :home,
      recent_article: recent_article,
      recent_article_path: recent_article_path(recent_article)
    )
  end

  defp recent_article_path(nil), do: nil

  defp recent_article_path(%{category: "review", slug: slug}) do
    ~p"/reviews/#{slug}"
  end

  defp recent_article_path(%{slug: slug}) do
    ~p"/writings/#{slug}"
  end
end
