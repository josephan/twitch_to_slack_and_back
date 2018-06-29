defmodule SlackServer do
  use Slack

  @channel Application.get_env(:twitch_slack, :slack_channel)

  def handle_event(message = %{type: "message", user: user}, slack, state) do
    # user = Slack.Web.Users.info(user)
    # TwitchServer.send_to_slack("Hello to you too!")
    {:ok, state}
  end

  def handle_event(_, _, state), do: {:ok, state}

  def send_to_twitch(username, message) do

  end
end
