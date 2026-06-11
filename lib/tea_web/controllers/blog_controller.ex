defmodule TeaWeb.BlogController do
  use TeaWeb, :controller

  alias Tea.Blog

  def index(conn, _params) do
    render(conn, :index, articles: Blog.list_articles())
  end

  def show(conn, %{"slug" => slug}) do
    case Blog.get_article(slug) do
      nil ->
        conn
        |> put_status(:not_found)
        |> render(TeaWeb.ErrorHTML, "404")

      article ->
        render(conn, :show, article: article)
    end
  end
end
