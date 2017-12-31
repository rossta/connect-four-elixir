defmodule ConnectFour.ServerTest do
  use ExUnit.Case
  require Logger

  alias ConnectFour.{Server, Board}

  setup do
    {:ok, server} = Server.start_link("abc")
    %{server: server}
  end

  test "join adds two players", %{server: server} do
    {:ok, _} = Server.join(server, "player_1", self())
    {:ok, _} = Server.join(server, "player_2", self())

    %{red: "player_1", black: "player_2"} = Server.game(server)
  end

  test "join adds too many players", %{server: server} do
    {:ok, _} = Server.join(server, "player_1", self())
    {:ok, _} = Server.join(server, "player_2", self())
    {:fail, game} = Server.join(server, "player_3", self())

    assert game.red != "player_3"
    assert game.black != "player_3"
  end

  test "join adds same player twice", %{server: server} do
    {:ok, _} = Server.join(server, "player_1", self())
    {:ok, _} = Server.join(server, "player_1", self())

    %{red: "player_1", black: nil} = Server.game(server)
  end

  # test "terminates when player goes down", %{server: server} do
  #   ref = Process.monitor(server)
  #   pid = spawn fn -> nil end
  #   {:ok, _} = Server.join(server, "player_1", pid)
  #   Process.exit(pid, :kill)
  #
  #   assert_receive {:DOWN, ^ref, :process, ^server, :normal}
  # end

  test "whereis for nonexisting game" do
    assert :undefined == Server.whereis("unfound")
  end

  test "whereis for existing game" do
    pid = Server.whereis("abc")

    %{id: "abc"} = Server.game(pid)
    assert Process.alive?(pid)
  end

  test "move first", %{server: server} do
    Server.join(server, "player_1", self())
    Server.join(server, "player_2", self())

    row = 0
    col = 3
    {:ok, _} = Server.move(server, "player_1", col)
    %{board: board, turns: [turn]} = Server.game(server)

    assert ^turn = {col, :red}
    assert {^row, ^col, :red} = Board.checker(board, {row, col})
  end

  test "move out of turn", %{server: server} do
    Server.join(server, "player_1", self())
    Server.join(server, "player_2", self())

    {:ok, _} = Server.move(server, "player_1", 0)
    {:foul, "Out of turn"} = Server.move(server, "player_1", 1)
  end

  test "move by nonplayer", %{server: server} do
    Server.join(server, "player_1", self())
    Server.join(server, "player_2", self())

    {:foul, "Player not playing"} = Server.move(server, "nonplayer", 1)
  end
end
