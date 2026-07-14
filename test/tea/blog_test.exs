defmodule Tea.BlogTest do
  use ExUnit.Case, async: false

  alias Tea.Blog

  @tag :tmp_dir
  test "loads articles from the runtime articles directory", %{tmp_dir: tmp_dir} do
    articles_dir = Path.join(tmp_dir, "articles")
    File.mkdir_p!(articles_dir)

    File.write!(Path.join(articles_dir, "runtime-post.md"), """
    ---
    title: Runtime Post
    excerpt: Loaded from a runtime-configured article directory.
    date: 2026-07-08
    tags: runtime, release
    ---

    # Runtime Post

    This article should be found from the configured directory.
    """)

    original_articles_dir = Application.get_env(:tea, :articles_dir)
    Application.put_env(:tea, :articles_dir, articles_dir)

    on_exit(fn ->
      if original_articles_dir do
        Application.put_env(:tea, :articles_dir, original_articles_dir)
      else
        Application.delete_env(:tea, :articles_dir)
      end
    end)

    assert [
             %{
               slug: "runtime-post",
               title: "Runtime Post",
               category: "writing",
               html: html
             }
           ] = Blog.list_articles()

    assert html =~ "<h1>Runtime Post</h1>"
  end

  @tag :tmp_dir
  test "hides draft articles when drafts are disabled", %{tmp_dir: tmp_dir} do
    articles_dir = Path.join(tmp_dir, "articles")
    File.mkdir_p!(articles_dir)

    write_article!(articles_dir, "published-post", "Published Post", draft?: false)
    write_article!(articles_dir, "draft-post", "Draft Post", draft?: true)

    with_blog_config(articles_dir, false, fn ->
      assert [%{slug: "published-post", draft?: false}] = Blog.list_articles()
      refute Blog.get_article("draft-post")
    end)
  end

  @tag :tmp_dir
  test "shows draft articles when drafts are enabled", %{tmp_dir: tmp_dir} do
    articles_dir = Path.join(tmp_dir, "articles")
    File.mkdir_p!(articles_dir)

    write_article!(articles_dir, "published-post", "Published Post", draft?: false)
    write_article!(articles_dir, "draft-post", "Draft Post", draft?: true)

    with_blog_config(articles_dir, true, fn ->
      assert [%{slug: "draft-post", draft?: true}, %{slug: "published-post", draft?: false}] =
               Blog.list_articles()

      assert %{slug: "draft-post", draft?: true} = Blog.get_article("draft-post")
    end)
  end

  defp write_article!(articles_dir, slug, title, opts) do
    draft_line =
      if Keyword.fetch!(opts, :draft?) do
        "draft: true\n"
      else
        ""
      end

    File.write!(Path.join(articles_dir, "#{slug}.md"), """
    ---
    title: #{title}
    excerpt: A test article.
    date: 2026-07-08
    #{draft_line}tags: test
    ---

    # #{title}

    This article exists for tests.
    """)
  end

  defp with_blog_config(articles_dir, show_drafts?, fun) do
    original_articles_dir = Application.get_env(:tea, :articles_dir)
    original_show_drafts = Application.get_env(:tea, :show_drafts)

    Application.put_env(:tea, :articles_dir, articles_dir)
    Application.put_env(:tea, :show_drafts, show_drafts?)

    try do
      fun.()
    after
      restore_env(:articles_dir, original_articles_dir)
      restore_env(:show_drafts, original_show_drafts)
    end
  end

  defp restore_env(key, nil), do: Application.delete_env(:tea, key)
  defp restore_env(key, value), do: Application.put_env(:tea, key, value)
end
