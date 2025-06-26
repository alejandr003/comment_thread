defmodule CommentThread.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      CommentThreadWeb.Telemetry,
      CommentThread.Repo,
      {DNSCluster, query: Application.get_env(:comment_thread, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: CommentThread.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: CommentThread.Finch},
      # Start a worker by calling: CommentThread.Worker.start_link(arg)
      # {CommentThread.Worker, arg},
      # Start to serve requests, typically the last entry
      CommentThreadWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CommentThread.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CommentThreadWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
