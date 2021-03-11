require '../advent.rb'
require 'set'

@input = Input.new(20)

DECKS = @input.text.split("\n\n").map{|deck| deck.lines(chomp: true)[1..].map(&:to_i) }
SIZE = DECKS[0].size

def bree a, b
  a.hash + b.hash
end

@games = 0
def recursive_combat deck_a, deck_b
  seen = Set.new
  @games += 1
  p @games

  until deck_a.empty? || deck_b.empty?
    return [1, deck_a, deck_b] if seen.include?(bree(deck_a, deck_b))
    seen.add(bree(deck_a, deck_b))

    card_a = deck_a[0]
    card_b = deck_b[0]

    winner = 0

    if deck_a.size > card_a && deck_b.size > card_b
      winner, = recursive_combat deck_a[1..card_a], deck_b[1..card_b]
    elsif card_a > card_b
      winner = 1
    else
      winner = 2
    end

    deck_a.shift
    deck_b.shift

    if winner == 1
      deck_a += [card_a, card_b]
    else
      deck_b += [card_b, card_a]
    end
  end

  return [deck_a.empty? ? 2 : 1, deck_a, deck_b]
end

winner, *decks = recursive_combat DECKS[0], DECKS[1]

pp winner, decks
pp decks[winner-1].reverse.map.with_index { |c, ii| c * (ii + 1) }.sum

# 31587 correct
# 34181 too high 