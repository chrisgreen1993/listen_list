defmodule ListenList.SubscribersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ListenList.Subscribers` context.
  """

  @doc """
  Generate a subscriber.
  """
  def subscriber_fixture(attrs \\ %{}) do
    {:ok, subscriber} =
      attrs
      |> Enum.into(%{
        confirmed_at: ~U[2024-05-22 06:02:00.000000Z],
        email: "some email",
        name: "some name"
      })
      |> ListenList.Subscribers.create_subscriber()

    subscriber
  end
end
