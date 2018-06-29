defmodule TwitchSlackTest do
  use ExUnit.Case
  doctest TwitchSlack

  test "greets the world" do
    assert TwitchSlack.hello() == :world
  end
end
