defmodule ListenList.Repo do
  use Ecto.Repo,
    otp_app: :listen_list,
    adapter: Ecto.Adapters.Postgres
end
