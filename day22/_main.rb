require '../advent.rb'
require 'set'

@input = Input.new(20)

DECKS = @input.text.split("\n\n").map{|deck| deck.lines(chomp: true)[1..].map(&:to_i) }
SIZE = DECKS[0].size

# deck_a = DECKS[0]
# deck_b = DECKS[1]

# until deck_a.empty? or deck_b.empty?
#   card_a = deck_a.shift
#   card_b = deck_b.shift
#   if card_a > card_b 
#     deck_a << card_a
#     deck_a << card_b
#   else
#     deck_b << card_b
#     deck_b << card_a
#   end 
# end

# pp deck_a, deck_b
# pp deck_a.concat(deck_b).reverse.each.with_index(1).reduce(0) {|sum, v| sum + (v[0]*v[1]) }

deck_a = DECKS[0]
deck_b = DECKS[1]

@game = 0


def recursive_combat deck_a, deck_b
  seen = Set.new
  # puts "=== Game #{@game += 1} ==="
  round = 0

  until deck_a.empty? or deck_b.empty?
    # puts "-- Round #{round += 1} --"

    puts "Deck A: #{deck_a}"
    puts "Deck B: #{deck_b}"
    puts "Card A: #{deck_a[0]}"
    puts "Card B: #{deck_b[0]}"

    winner = nil
    if seen === deck_a + deck_b
      winner = :deck_a
    end

    original_deck_a = deck_a.clone
    original_deck_b = deck_b.clone
    card_a = deck_a.shift
    card_b = deck_b.shift

    if deck_a.size >= card_a && deck_b.size >= card_b
      # puts "NEW  GAME"
      decks = recursive_combat deck_a.clone, deck_b.clone
      if decks[1].empty?
        winner = :deck_a
      else
        winner = :deck_b
      end
      # puts "END GAME"
    end

    # puts "The winner is: #{winner == :deck_a or card_a > card_b ? "A" : "B"}"

    if winner
      if winner == :deck_a
        deck_a << card_a
        deck_a << card_b
      else
        deck_b << card_b
        deck_b << card_a
      end
    else
      if card_b > card_a
        deck_b << card_b
        deck_b << card_a
      else
        deck_a << card_a
        deck_a << card_b
      end
    end

    seen.add original_deck_a + original_deck_b
  end
  
  # puts "Game #{@game} Result: #{[deck_a, deck_b]}"
  [deck_a, deck_b]
end

deck = recursive_combat deck_a, deck_b
pp deck
pp deck.flatten.reverse.each.with_index(1).reduce(0) {|sum, v| sum + (v[0]*v[1]) }