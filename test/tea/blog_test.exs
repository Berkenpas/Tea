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
end
