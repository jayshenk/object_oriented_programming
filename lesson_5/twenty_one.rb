require 'pry'

module Hand
  def display_hand(hidden: false)
    if hidden
      "#{hand[0]} and ?"
    else
      hand.join(', ')
    end
  end

  def hit(card)
    hand << card
  end

  def busted?
    total > 21
  end

  def total
    values = hand.map(&:value)

    sum = 0
    values.each do |value|
      if value == "A"
        sum += 11
      elsif value.to_i == 0 # J, Q, K
        sum += 10
      else
        sum += value.to_i
      end
    end

    # correct for Aces
    values.count { |value| value == "A" }.times do
      sum -= 10 if sum > 21
    end

    sum
  end
end

class Participant
  include Hand

  attr_accessor :hand

  def initialize
    @hand = []
  end
end

class Player < Participant
  attr_accessor :name

  def initialize
    super
    set_name
  end

  def set_name
    puts "What is your name?"
    answer = nil
    loop do
      answer = gets.chomp
      break unless answer.empty?
      puts "Sorry, you must enter a name:"
    end
    self.name = answer
  end
end

class Deck
  SUITS = ['H', 'D', 'C', 'S']
  VALUES = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A']

  attr_reader :cards

  def initialize
    @cards = []
    SUITS.each do |suit|
      VALUES.each do |value|
        @cards << Card.new(suit, value)
      end
    end
    @cards.shuffle!
  end

  def deal
    cards.pop
  end
end

class Card
  attr_reader :suit, :value

  def initialize(suit, value)
    @suit = suit
    @value = value
  end

  def to_s
    "[#{suit}, #{value}]"
  end
end

class Game
  attr_accessor :deck, :player, :dealer

  def initialize
    system 'clear'
    @deck = Deck.new
    @player = Player.new
    @dealer = Participant.new
  end

  def start
    deal_cards
    show_initial_cards
    player_turn
    dealer_turn
    show_result
    detect_winner
    display_winner
  end

  def deal_cards
    2.times do
      player.hand << deck.deal
      dealer.hand << deck.deal
    end
  end

  def show_initial_cards
    puts "Dealer has: #{dealer.display_hand(hidden: true)}"
    puts "#{player.name} has: #{player.display_hand}"
  end

  def player_turn
    loop do
      choice = nil
      loop do
        puts "Would you like to (h)it or (s)tay?"
        choice = gets.chomp.downcase
        break if ['h', 's'].include?(choice)
        puts "Sorry, you must enter 'h' or 's'."
      end

      if choice == 'h'
        player.hit(deck.deal)
        puts "You chose to hit!"
        show_initial_cards
      end

      break if choice == 's' || player.busted?
    end

    puts "You stayed at #{player.total}." unless player.busted?
  end

  def dealer_turn
    loop do
      break if dealer.busted? || dealer.total >= 17
      puts "Dealer hits!"
      dealer.hit(deck.deal)
      puts "Dealer's cards are now: #{dealer.display_hand}"
    end

    puts "Dealer stays." unless dealer.busted?
  end

  def show_result
    puts "Dealer has #{dealer.display_hand} with a total of #{dealer.total}"
    puts "#{player.name} has #{player.display_hand} with a total of #{player.total}"
  end

  def detect_winner
    if player.total > 21
      :player_busted
    elsif dealer.total > 21
      :dealer_busted
    elsif dealer.total < player.total
      :player
    elsif dealer.total > player.total
      :dealer
    else
      :tie
    end
  end

  def display_winner
    case detect_winner
    when :player_busted
      puts "#{player.name} busted! Dealer wins!"
    when :dealer_busted
      puts "Dealer busted! #{player.name} wins!"
    when :player
      puts "#{player.name} wins!"
    when :dealer
      puts "Dealer wins!"
    when :tie
      puts "It's a tie!"
    end
  end
end

Game.new.start
