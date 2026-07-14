defmodule TeaWeb.UserSessionController do
  use TeaWeb, :controller

  alias TeaWeb.UserAuth

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UserAuth.log_out_user()
  end
end
