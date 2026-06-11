defmodule Tea.Blog do
  @moduledoc """
  Loads markdown files from priv/articles and exposes them as blog posts.
  """

  @articles_glob Path.join([:code.priv_dir(:tea), "articles", "*.md"])

  def list_articles do
    @articles_glob
    |> Path.wildcard()
    |> Enum.map(&parse_article_file/1)
    |> Enum.sort_by(& &1.date, {:desc, Date})
  end

  def get_article(slug) when is_binary(slug) do
    list_articles()
    |> Enum.find(&(&1.slug == slug))
  end

  defp parse_article_file(path) do
    body = File.read!(path)
    slug = path |> Path.basename(".md")

    {frontmatter, markdown} = parse_frontmatter(body)

    {:ok, html, _warnings} =
      Earmark.as_html(markdown,
        smartypants: false,
        pure_links: true,
        code_class_prefix: "language-"
      )

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
      tags: tags,
      html: html
    }
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
