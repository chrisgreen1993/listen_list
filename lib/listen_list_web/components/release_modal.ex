defmodule ListenListWeb.Components.ReleaseModal do
  use Phoenix.Component

  alias Phoenix.LiveView.JS
  import Phoenix.HTML
  import ListenListWeb.CoreComponents

  attr :release, :map
  attr :on_cancel, :string

  def release_modal(assigns) do
    ~H"""
    <.modal :if={@release} id="release-modal" show on_cancel={JS.push(@on_cancel)}>
      <h2 class="font-bold text-xl mb-2"><%= @release.album %></h2>
      <p class="text-gray-700 text-base"><%= @release.artist %></p>
      <div :if={@release.embed} class="[&>iframe]:w-full mt-4">
        <%= raw(HtmlEntities.decode(@release.embed["html"])) %>
      </div>
      <p class="text-gray-700 mt-4">
        Links: <a href={@release.post_url} target="_blank" class="text-blue-400 underline">Reddit</a>
        |
        <a href={@release.url} target="_blank" class="text-blue-400 underline">
          <%= URI.parse(@release.url).host %>
        </a>
      </p>
    </.modal>
    """
  end
end
