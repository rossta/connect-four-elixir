defmodule ConnectFour.Games.ServerTest do
  use ExUnit.Case
  require Logger

  # alias ConnectFour.Games.{Server, Game}
  alias ConnectFour.Games.Server

  setup do
    {:ok, server} = Server.start_link("abc")
    %{server: server}
  end

  test "join adds two players", %{server: server} do
    {:ok, _} = Server.join(server, "player_1", self())
    {:ok, _} = Server.join(server, "player_2", self())

    %{red: red, black: black} = Server.game(server)
    assert red == "player_1"
    assert black == "player_2"
  end

  test "join adds too many players", %{server: server} do
    {:ok, _} = Server.join(server, "player_1", self())
    {:ok, _} = Server.join(server, "player_2", self())
    {:error, reason} = Server.join(server, "player_3", self())

    assert reason == "Already two players playing"
  end

  test "join adds same player twice", %{server: server} do
    {:ok, _} = Server.join(server, "player_1", self())
    {:ok, _} = Server.join(server, "player_1", self())

    %{red: red, black: black} = Server.game(server)

    assert red == "player_1"
    assert black == nil
  end

  test "terminates when player goes down", %{server: server} do
    ref = Process.monitor(server)
    pid = spawn fn -> nil end
    {:ok, _} = Server.join(server, "player_1", pid)
    Process.exit(pid, :kill)

    assert_receive {:DOWN, ^ref, :process, ^server, :normal}
  end

  test "whereis for nonexisting game" do
    assert :undefined == Server.whereis("unfound")
  end

  test "whereis for existing game" do
    pid = Server.whereis("abc")

    %{id: id} = Server.game(pid)
    assert id == "abc"
    assert Process.alive?(pid)
  end

  test "move first", %{server: server} do
    Server.join(server, "player_1", self())
    Server.join(server, "player_2", self())

    row = 0
    col = 3
    :ok = Server.move(server, "player_1", col)
    %{board: board, last: last, turns: [turn]} = Server.game(server)

    assert last == "player_1"
    assert turn = {:red, col}
    assert Map.get(board.cells, "#{row}#{col}", {row, col, :red})
  end

  test "move out of turn", %{server: server} do
    Server.join(server, "player_1", self())
    Server.join(server, "player_2", self())

    :ok = Server.move(server, "player_1", 0)
    {:foul, reason} = Server.move(server, "player_1", 1)
    assert reason == "Not player's turn"
  end

  test "move by nonplayer", %{server: server} do
    Server.join(server, "player_1", self())
    Server.join(server, "player_2", self())

    {:foul, reason} = Server.move(server, "nonplayer", 1)
    assert reason == "Player not playing"
  end
end
