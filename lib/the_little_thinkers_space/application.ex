defmodule TheLittleThinkersSpace.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      TheLittleThinkersSpace.Repo,
      # Start the Telemetry supervisor
      TheLittleThinkersSpaceWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: TheLittleThinkersSpace.PubSub},
      # Start the Endpoint (http/https)
      TheLittleThinkersSpaceWeb.Endpoint,
      ExRoboCop.start(),
      # Start the cache
      {ConCache,
       [
         name: :upload_cache,
         ttl_check_interval: 60_000,
         global_ttl: 604_800_000
       ]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TheLittleThinkersSpace.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TheLittleThinkersSpaceWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
