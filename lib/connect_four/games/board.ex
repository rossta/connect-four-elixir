defmodule ConnectFour.Games.Board do
  @derive [Poison.Encoder]
  alias ConnectFour.Games.Board
  require Logger

  @rows 6
  @cols 7

  defstruct [
    rows: nil,
    cols: nil,
    cells: nil
  ]

  def new() do
    %Board{rows: @rows, cols: @cols, cells: Map.new}
  end

  def drop_checker(board, {col, color}) do
    case open_row(board, col) do
      :none ->
        {:error, :full_column}

      row ->
        %{board | cells: Map.put(board.cells, cell_key(row, col), {row, col, color})}
    end
  end

  def checker(board, {row, col}) do
    case Map.fetch(board.cells, cell_key(row, col)) do
      {:ok, checker} -> checker
      :error -> {row, col, :empty}
    end
  end

  defp open_row(%{rows: rows} = board, col) do
    row = board.cells
          |> Map.values
          |> Enum.filter(fn {_, c, _} -> col == c end)
          |> Enum.map(fn {row, _, _} -> row end)
          |> Enum.max(fn -> -1 end)

    case row do
      row when row+1 >= rows -> :none

      row -> row + 1
    end
  end

  def cell_key(row, col) do
    "#{row}#{col}"
  end
end

defimpl Poison.Encoder, for: ConnectFour.Games.Board do
  @moduledoc """
  Implements Poison.Encoder for Board
  """
  def encode(%ConnectFour.Games.Board{rows: rows, cols: cols, cells: cells}, _options)  do
    cells = for {key, {row, col, color}} <- cells, into: %{} do
      {key, %{row: row, col: col, color: color}}
    end

    Poison.encode!(%{rows: rows, cols: cols, cells: cells})
  end

  def encode(board, _options) do
    raise Poison.EncodeError, value: board
  end
end
