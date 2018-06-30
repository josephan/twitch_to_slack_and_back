defmodule SlackServer do
  use Slack

  @channel_id Application.get_env(:twitch_slack, :slack_channel_id)

  def broadcast(message) do
    send(SlackServer, {:broadcast, message})
  end

  def handle_event(message = %{type: "message", user: user}, slack, state) do
    if valid_channel?(message) do
      message
      |> build_message(slack)
      |> TwitchServer.broadcast()
    end
    {:ok, state}
  end

  def handle_event(_, _, state), do: {:ok, state}

  def handle_info({:broadcast, message}, slack, state) do
    send_message(message, @channel_id, slack)
    {:ok, state}
  end

  def handle_info(_, _, state), do: {:ok, state}

  defp valid_channel?(%{channel: channel_id}) do
    channel_id == @channel_id
  end

  defp build_message(message, slack) do
    text = message.text
    name = slack.users[message.user].name

    "#{name}: #{text}"
  end
end
