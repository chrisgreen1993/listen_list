defmodule ListenListWeb.Components.SubscribeModal do
  use Phoenix.Component

  alias Phoenix.LiveView.JS
  import ListenListWeb.CoreComponents

  attr :on_cancel, :string

  def subscribe_modal(assigns) do
    ~H"""
    <.modal id="subscribe-modal" show on_cancel={JS.push(@on_cancel)}>
      <h2 class="font-bold text-xl mb-4">Sign up for our weekly email</h2>
      <p class="mb-4">
        Enter your details and we'll send you a weekly email with the best new music
      </p>
      <.simple_form for={nil} phx-submit="create_subscriber" class="max-w-sm">
        <.input name="name" label="Name" placeholder="Name" value="" required />
        <.input type="email" name="email" label="Email" placeholder="Email" value="" required />
        <:actions>
          <button
            class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded"
            phx-click="show_subscribe_modal"
          >
            Sign me up!
          </button>
        </:actions>
      </.simple_form>
    </.modal>
    """
  end
end
