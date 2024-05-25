defmodule ListenListWeb.Components do
  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__).{
        ReleaseCard,
        PeriodHeader,
        ReleaseModal,
        SubscribeModal
      }
    end
  end
end
