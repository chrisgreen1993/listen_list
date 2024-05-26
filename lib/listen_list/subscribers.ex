defmodule ListenList.Subscribers do
  @moduledoc """
  The Subscribers context.
  """

  import Ecto.Query, warn: false
  alias ListenList.Repo

  alias ListenList.Subscribers.Subscriber
  alias ListenList.Subscribers.Token

  @doc """
  Returns the list of subscribers.

  ## Examples

      iex> list_subscribers()
      [%Subscriber{}, ...]

  """
  def list_subscribers do
    Repo.all(Subscriber)
  end

  def list_confirmed_subscribers do
    Repo.all(from s in Subscriber, where: not is_nil(s.confirmed_at))
  end

  @doc """
  Gets a single subscriber.

  Raises `Ecto.NoResultsError` if the Subscriber does not exist.

  ## Examples

      iex> get_subscriber!(123)
      %Subscriber{}

      iex> get_subscriber!(456)
      ** (Ecto.NoResultsError)

  """
  def get_subscriber!(id), do: Repo.get!(Subscriber, id)

  @doc """
  Creates a subscriber.

  ## Examples

      iex> create_subscriber(%{field: value})
      {:ok, %Subscriber{}}

      iex> create_subscriber(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_subscriber(attrs \\ %{}) do
    %Subscriber{}
    |> Subscriber.changeset(attrs)
    |> Repo.insert(
      conflict_target: :email,
      on_conflict: {:replace_all_except, [:inserted_at, :id]}
    )
  end

  def confirm_subscriber_by_token(token) do
    with {:ok, id} <- Token.verify_confirm_token(token),
         subscriber when not is_nil(subscriber) <- Repo.get(Subscriber, id) do
      subscriber
      |> Subscriber.confirm_changeset()
      |> Repo.update()
    else
      nil -> {:error, :not_found}
      _ -> {:error, :invalid_token}
    end
  end

  @doc """
  Updates a subscriber.

  ## Examples

      iex> update_subscriber(subscriber, %{field: new_value})
      {:ok, %Subscriber{}}

      iex> update_subscriber(subscriber, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_subscriber(%Subscriber{} = subscriber, attrs) do
    subscriber
    |> Subscriber.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a subscriber.

  ## Examples

      iex> delete_subscriber(subscriber)
      {:ok, %Subscriber{}}

      iex> delete_subscriber(subscriber)
      {:error, %Ecto.Changeset{}}

  """
  def delete_subscriber(%Subscriber{} = subscriber) do
    Repo.delete(subscriber)
  end

  def delete_subscriber_by_token(token) do
    with {:ok, id} <- Token.verify_unsubscribe_token(token),
         subscriber when not is_nil(subscriber) <- Repo.get(Subscriber, id) do
      Repo.delete(subscriber)
    else
      nil -> {:error, :not_found}
      _ -> {:error, :invalid_token}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking subscriber changes.

  ## Examples

      iex> change_subscriber(subscriber)
      %Ecto.Changeset{data: %Subscriber{}}

  """
  def change_subscriber(%Subscriber{} = subscriber, attrs \\ %{}) do
    Subscriber.changeset(subscriber, attrs)
  end
end
