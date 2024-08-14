defmodule Blackjack.PlayerStrategy do
  @callback should_hit?(hand :: list, dealer_card :: any) :: boolean
end
