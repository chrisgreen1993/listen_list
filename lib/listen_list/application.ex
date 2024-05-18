defmodule ListenList.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ListenListWeb.Telemetry,
      ListenList.Repo,
      {DNSCluster, query: Application.get_env(:listen_list, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ListenList.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: ListenList.Finch},
      # Start a worker by calling: ListenList.Worker.start_link(arg)
      # {ListenList.Worker, arg},
      # Start to serve requests, typically the last entry
      ListenListWeb.Endpoint
    ]

    children =
      if Application.get_env(:listen_list, :enable_jobs, false) do
        children ++ [ListenList.Scheduler]
      else
        children
      end

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ListenList.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ListenListWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
