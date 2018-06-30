defmodule TwitchServer do
  use GenServer

  defmodule Config do
    defstruct server:  "irc.chat.twitch.tv",
              port:    6667,
              pass:    Application.get_env(:twitch_slack, :twitch_chat_oauth),
              nick:    "ranked_fun",
              channel: "#ranked_fun",
              client:  nil,
              user: "ranked_fun"

    def from_params(params) when is_map(params) do
      Enum.reduce(params, %Config{}, fn {k, v}, acc ->
        case Map.has_key?(acc, k) do
          true  -> Map.put(acc, k, v)
          false -> acc
        end
      end)
    end
  end

  # API

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [%Config{}], name: __MODULE__)
  end

  def broadcast(message) do
    client = :sys.get_state(__MODULE__) |> Map.get(:client)
    ExIrc.Client.msg(client, :privmsg, "#ranked_fun", message)
  end

  # Callbacks

  def init([config]) do
    {:ok, client}  = ExIrc.start_link!()
    ExIrc.Client.add_handler client, self()
    ExIrc.Client.connect! client, config.server, config.port

    {:ok, %Config{config | :client => client}}
  end

  def handle_info({:connected, _server, _port}, config) do
    ExIrc.Client.logon config.client, config.pass, config.nick, config.nick, config.nick
    {:noreply, config}
  end
  def handle_info(:logged_in, config) do
    ExIrc.Client.join config.client, config.channel
    {:noreply, config}
  end
  def handle_info({:unrecognized, _, _}, config) do
    {:noreply, config}
  end
  def handle_info({:joined, _}, config) do
    {:noreply, config}
  end
  def handle_info({:joined, _, _}, config) do
    {:noreply, config}
  end
  def handle_info({:names_list, _, _}, config) do
    {:noreply, config}
  end

  def handle_info({:received, message, %{user: user}, _channel}, config) do
    message = build_message(user, message)
    SlackServer.broadcast(message)
    {:noreply, config}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

  defp build_message(username, message) do
    "#{username}: #{message}"
  end
end
