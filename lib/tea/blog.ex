defmodule Tea.Blog do
  @moduledoc """
  Loads markdown files from priv/articles and exposes them as blog posts.
  """

  def list_articles do
    articles_glob()
    |> Path.wildcard()
    |> Enum.map(&parse_article_file/1)
    |> Enum.reject(&hidden_draft?/1)
    |> Enum.sort_by(& &1.date, {:desc, Date})
  end

  def list_writings do
    list_by_category("writing")
  end

  def list_reviews do
    list_by_category("review")
  end

  def get_article(slug) when is_binary(slug) do
    list_articles()
    |> Enum.find(&(&1.slug == slug))
  end

  def get_article(slug, category) when is_binary(slug) and is_binary(category) do
    list_articles()
    |> Enum.find(&(&1.slug == slug and &1.category == category))
  end

  defp list_by_category(category) do
    list_articles()
    |> Enum.filter(&(&1.category == category))
  end

  defp articles_glob do
    Path.join([articles_dir(), "*.md"])
  end

  defp articles_dir do
    Application.get_env(:tea, :articles_dir) || Path.join(:code.priv_dir(:tea), "articles")
  end

  defp parse_article_file(path) do
    body = File.read!(path)
    slug = path |> Path.basename(".md")

    {frontmatter, markdown} = parse_frontmatter(body)

    html = MDEx.to_html!(markdown, extension: [autolink: true])

    date =
      frontmatter
      |> Map.get("date", Date.utc_today() |> Date.to_iso8601())
      |> Date.from_iso8601!()

    tags =
      frontmatter
      |> Map.get("tags", "")
      |> String.split(",", trim: true)
      |> Enum.map(&String.trim/1)

    %{
      slug: slug,
      title: Map.get(frontmatter, "title", slug_to_title(slug)),
      excerpt: Map.get(frontmatter, "excerpt", ""),
      date: date,
      category: category(frontmatter),
      draft?: draft?(frontmatter),
      tags: tags,
      rating: rating(frontmatter),
      html: html
    }
  end

  defp hidden_draft?(article) do
    article.draft? and not show_drafts?()
  end

  defp show_drafts? do
    Application.get_env(:tea, :show_drafts, false)
  end

  defp draft?(frontmatter) do
    frontmatter
    |> Map.get("draft", "false")
    |> String.downcase()
    |> String.trim()
    |> Kernel.in(["true", "yes", "1"])
  end

  defp rating(frontmatter) do
    case Float.parse(Map.get(frontmatter, "rating", "")) do
      {rating, ""} when rating >= 1 and rating <= 10 -> rating
      _ -> nil
    end
  end

  defp category(frontmatter) do
    case Map.get(frontmatter, "category", "writing") |> String.downcase() |> String.trim() do
      "review" -> "review"
      "reviews" -> "review"
      _ -> "writing"
    end
  end

  defp parse_frontmatter("---\n" <> rest) do
    [raw_meta, markdown] = String.split(rest, "\n---\n", parts: 2)

    meta =
      raw_meta
      |> String.split("\n", trim: true)
      |> Enum.reduce(%{}, fn line, acc ->
        case String.split(line, ":", parts: 2) do
          [key, value] -> Map.put(acc, String.trim(key), String.trim(value))
          _ -> acc
        end
      end)

    {meta, markdown}
  rescue
    MatchError -> {%{}, rest}
  end

  defp parse_frontmatter(markdown), do: {%{}, markdown}

  defp slug_to_title(slug) do
    slug
    |> String.replace("-", " ")
    |> String.split(" ", trim: true)
    |> Enum.map_join(" ", &String.capitalize/1)
  end
end
