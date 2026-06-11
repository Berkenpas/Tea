defmodule TeaWeb.BlogController do
  use TeaWeb, :controller

  alias Tea.Blog

  def articles(conn, _params) do
    redirect(conn, to: ~p"/writings")
  end

  def article(conn, %{"slug" => slug}) do
    redirect(conn, to: ~p"/writings/#{slug}")
  end

  def writings(conn, _params) do
    render_index(conn,
      articles: Blog.list_writings(),
      section_label: "Writings",
      section_title: "Writings",
      section_description: "Unrelated notes, essays, and project logs from Berkenpas.",
      section_path: ~p"/writings",
      empty_title: "No writings yet",
      empty_description: "Add a markdown file to priv/articles to publish the first writing."
    )
  end

  def reviews(conn, _params) do
    render_index(conn,
      articles: Blog.list_reviews(),
      section_label: "Reviews",
      section_title: "Reviews",
      section_description:
        "Considered notes on teas, tools, places, and objects worth revisiting.",
      section_path: ~p"/reviews",
      empty_title: "No reviews yet",
      empty_description: "Add category: review to a markdown file when the first review is ready."
    )
  end

  def writing(conn, %{"slug" => slug}) do
    render_article(conn, slug, "writing", "Writings", ~p"/writings")
  end

  def review(conn, %{"slug" => slug}) do
    render_article(conn, slug, "review", "Reviews", ~p"/reviews")
  end

  defp render_index(conn, assigns) do
    render(conn, :index, assigns)
  end

  defp render_article(conn, slug, category, section_label, section_path) do
    case Blog.get_article(slug, category) do
      nil ->
        conn
        |> put_status(:not_found)
        |> put_view(html: TeaWeb.ErrorHTML)
        |> render(:"404")

      article ->
        render(conn, :show,
          article: article,
          section_label: section_label,
          section_path: section_path
        )
    end
  end
end
