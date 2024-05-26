defmodule ListenList.Subscribers.Token do
  alias Phoenix.Token

  @namespace "subscriber"

  def sign_confirm_token(id) do
    Token.sign(ListenListWeb.Endpoint, "#{@namespace}.confirm", id)
  end

  def verify_confirm_token(id) do
    # 24 hours
    max_age = 24 * 60 * 60
    Token.verify(ListenListWeb.Endpoint, "#{@namespace}.confirm", id, max_age: max_age)
  end

  def sign_unsubscribe_token(id) do
    Token.sign(ListenListWeb.Endpoint, "#{@namespace}.unsubscribe", id)
  end

  def verify_unsubscribe_token(id) do
    # No expiration so a user can always use the link
    max_age = :infinity
    Token.verify(ListenListWeb.Endpoint, "#{@namespace}.unsubscribe", id, max_age: max_age)
  end
end
