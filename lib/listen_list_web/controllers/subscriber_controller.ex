defmodule ListenListWeb.SubscriberController do
  use ListenListWeb, :controller

  alias ListenList.Subscribers

  def confirm(conn, %{"token" => token}) do
    case Subscribers.confirm_subscriber_by_token(token) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Email confirmed!")
        |> redirect(to: "/")

      {:error, _} ->
        conn
        |> put_flash(:error, "Unable to confirm email, please try again.")
        |> redirect(to: "/")
    end
  end
end
