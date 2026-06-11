defmodule TeaWeb.BlogHTML do
  @moduledoc """
  Templates for the markdown-backed blog.
  """
  use TeaWeb, :html

  embed_templates "blog_html/*"
end
