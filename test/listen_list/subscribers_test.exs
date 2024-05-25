defmodule ListenList.SubscribersTest do
  use ListenList.DataCase

  alias ListenList.Subscribers

  describe "subscribers" do
    alias ListenList.Subscribers.Subscriber

    import ListenList.SubscribersFixtures

    @invalid_attrs %{name: nil, email: nil, confirmed_at: nil}

    test "list_subscribers/0 returns all subscribers" do
      subscriber = subscriber_fixture()
      assert Subscribers.list_subscribers() == [subscriber]
    end

    test "list_confirmed_subscribers/0 returns all confirmed subscribers" do
      confirmed_subscriber =
        subscriber_fixture(%{email: "email1", confirmed_at: ~U[2024-05-22 06:02:00.000000Z]})

      subscriber_fixture(%{email: "email2", confirmed_at: nil})
      assert Subscribers.list_confirmed_subscribers() == [confirmed_subscriber]
    end

    test "get_subscriber!/1 returns the subscriber with given id" do
      subscriber = subscriber_fixture()
      assert Subscribers.get_subscriber!(subscriber.id) == subscriber
    end

    test "create_subscriber/1 with valid data creates a subscriber" do
      valid_attrs = %{
        name: "some name",
        email: "some email",
        confirmed_at: ~U[2024-05-22 06:02:00.000000Z]
      }

      assert {:ok, %Subscriber{} = subscriber} = Subscribers.create_subscriber(valid_attrs)
      assert subscriber.name == "some name"
      assert subscriber.email == "some email"
      assert subscriber.confirmed_at == ~U[2024-05-22 06:02:00.000000Z]
    end

    test "create_subscriber/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Subscribers.create_subscriber(@invalid_attrs)
    end

    test "update_subscriber/2 with valid data updates the subscriber" do
      subscriber = subscriber_fixture()

      update_attrs = %{
        name: "some updated name",
        email: "some updated email",
        confirmed_at: ~U[2024-05-23 06:02:00.000000Z]
      }

      assert {:ok, %Subscriber{} = subscriber} =
               Subscribers.update_subscriber(subscriber, update_attrs)

      assert subscriber.name == "some updated name"
      assert subscriber.email == "some updated email"
      assert subscriber.confirmed_at == ~U[2024-05-23 06:02:00.000000Z]
    end

    test "update_subscriber/2 with invalid data returns error changeset" do
      subscriber = subscriber_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Subscribers.update_subscriber(subscriber, @invalid_attrs)

      assert subscriber == Subscribers.get_subscriber!(subscriber.id)
    end

    test "delete_subscriber/1 deletes the subscriber" do
      subscriber = subscriber_fixture()
      assert {:ok, %Subscriber{}} = Subscribers.delete_subscriber(subscriber)
      assert_raise Ecto.NoResultsError, fn -> Subscribers.get_subscriber!(subscriber.id) end
    end

    test "change_subscriber/1 returns a subscriber changeset" do
      subscriber = subscriber_fixture()
      assert %Ecto.Changeset{} = Subscribers.change_subscriber(subscriber)
    end

    test "confirm_subscriber_by_token/1 confirms the subscriber if the token is valid" do
      subscriber = subscriber_fixture(%{confirmed_at: nil})
      token = Subscribers.generate_signed_token(subscriber.id)
      assert {:ok, %Subscriber{} = subscriber} = Subscribers.confirm_subscriber_by_token(token)
      assert %DateTime{} = subscriber.confirmed_at
    end

    test "confirm_subscriber_by_token/1 returns an error if the token is invalid" do
      assert {:error, :invalid_token} = Subscribers.confirm_subscriber_by_token("invalid token")
    end

    test "confirm_subscriber_by_token/1 returns an error if the subscriber is not found" do
      subscriber_fixture(%{confirmed_at: nil})
      token = Subscribers.generate_signed_token(123)
      assert {:error, :not_found} = Subscribers.confirm_subscriber_by_token(token)
    end
  end
end
