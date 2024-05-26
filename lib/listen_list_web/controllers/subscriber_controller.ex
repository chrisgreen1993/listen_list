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

  def unsubscribe(conn, %{"token" => token}) do
    case Subscribers.delete_subscriber_by_token(token) do
      {:ok, _} ->
        unsubscribe_successful(conn)

      {:error, :not_found} ->
        # Subscriber not found, but this is fine as it means they're already unsubscribed
        unsubscribe_successful(conn)

      {:error, _} ->
        conn
        |> put_flash(:error, "Unable to unsubscribe, please try again.")
        |> redirect(to: "/")
    end
  end

  defp unsubscribe_successful(conn) do
    conn
    |> put_flash(:info, "Unsubscribed!")
    |> redirect(to: "/")
  end
end
