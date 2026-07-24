defmodule TeaWeb.BlogHTML do
  @moduledoc """
  Templates for the markdown-backed blog.
  """
  use TeaWeb, :html

  embed_templates "blog_html/*"

  def rating_tone(rating) when rating <= 5, do: "rating-chip--low"
  def rating_tone(rating) when rating < 8, do: "rating-chip--medium"
  def rating_tone(rating) when rating < 10, do: "rating-chip--high"
  def rating_tone(_rating), do: "rating-chip--perfect"

  def format_rating(rating) when trunc(rating) == rating, do: trunc(rating)
  def format_rating(rating), do: rating
end
