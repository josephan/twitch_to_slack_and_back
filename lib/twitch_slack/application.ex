defmodule TwitchSlack.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      Slack.Bot.start_link(SlackServer, [], Application.get_env(:twitch_slack, :slack_api_token))
      {TwitchServer, []}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TwitchSlack.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
