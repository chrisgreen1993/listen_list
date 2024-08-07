defmodule ListenListWeb.Components.ReleaseCard do
  use Phoenix.Component

  attr :release, :map
  attr :on_click, :string
  attr :lazy_load?, :boolean, default: false
  attr :rest, :global

  def release_card(assigns) do
    ~H"""
    <div class="rounded overflow-hidden shadow-lg" {@rest}>
      <.link class="flex flex-col h-full" phx-click={@on_click} phx-value-id={@release.id}>
        <%= if @release.thumbnail_url do %>
          <img
            loading={if @lazy_load?, do: "lazy", else: "eager"}
            class="relative w-full aspect-square"
            src={@release.thumbnail_url}
            alt="Thumbnail"
          />
        <% else %>
          <div class="relative w-full aspect-square bg-gray-300"></div>
        <% end %>
        <div class="px-6 py-4 flex-grow">
          <h2 class="font-bold text-xl mb-2 line-clamp-2"><%= @release.album %></h2>
          <p class="text-gray-700 text-base line-clamp-2"><%= @release.artist %></p>
        </div>
        <p class="px-6 py-4 text-sm text-gray-600">
          <%= Calendar.strftime(@release.post_created_at, "%a, %B %d %Y") %>
        </p>
      </.link>
    </div>
    """
  end
end
