defmodule Excloud.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    keyId = System.get_env("keyID")
    appKey = System.get_env("applicationKey")
    token = Enum.join([keyId, appKey], ":")
    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      Excloud.Repo,
      # Start the endpoint when the application starts
      ExcloudWeb.Endpoint,
      {Excloud.Api.Server, token}
      # Starts a worker by calling: Excloud.Worker.start_link(arg)
      # {Excloud.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Excloud.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ExcloudWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
