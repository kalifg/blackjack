defmodule Blackjack.PlayerStrategyTest do
  alias Blackjack.Player

  import Blackjack.Sigils.Hand

  use ExUnit.Case

  doctest Blackjack.DealerStrategy
  doctest Blackjack.PlayTableStrategy
end
