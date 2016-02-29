class Move
  VALUES = ['rock', 'paper', 'scissors']

  def initialize(value)
    @value = value
  end

  def scissors?
    @value == 'scissors'
  end

  def rock?
    @value == 'rock'
  end

  def paper?
    @value == 'paper'
  end

  def >(other_move)
    (rock? && other_move.scissors?) ||
      (paper? && other_move.rock?) ||
      (scissors? && other_move.paper?)
  end

  def <(other_move)
    (rock? && other_move.paper?) ||
      (paper? && other_move.scissors?) ||
      (scissors? && other_move.rock?)
  end

  def to_s
    @value
  end
end

class Player
  attr_accessor :move, :name, :move_history

  def initialize
    set_name
    @move_history = []
  end

  def remember_move
    move_history << move.to_s
  end
end

class Human < Player
  def set_name
    n = ""
    loop do
      puts "What's your name?"
      n = gets.chomp
      break unless n.empty?
      puts "Sorry, must enter a value."
    end
    self.name = n
  end

  def choose
    choice = nil
    loop do
      puts "Please choose rock, paper, or scissors:"
      choice = gets.chomp
      break if Move::VALUES.include? choice
      puts "Sorry, invalid choice."
    end
    self.move = Move.new(choice)
  end
end

class Computer < Player
  attr_accessor :win_history, :smart_choices

  def initialize
    super
    set_smart_choices
  end

  def set_name
    self.name = ['R2D2', 'Hal', 'Chappie', 'Sonny', 'Number 5'].sample
  end

  def set_smart_choices
    self.smart_choices = case name
                         when 'R2D2'
                           { 'rock' => 1 }
                         when 'Hal'
                           { 'rock' => 1, 'scissors' => 4 }
                         when 'Chappie'
                           { 'rock' => 2, 'paper' => 4, 'scissors' => 2 }
                         else
                           { 'rock' => 3, 'paper' => 3, 'scissors' => 3 }
                         end
  end

  def choose
    smart_arr = []
    smart_choices.each do |choice, num|
      smart_arr += [choice] * num
    end
    self.move = Move.new(smart_arr.sample)
  end

  def update_smart_choices(result)
    choice = move.to_s
    if result == :loss
      smart_choices[choice] -= 1 unless smart_choices[choice] == 1
    elsif result == :win
      smart_choices[choice] += 1
    end
  end
end

# Game Orchestration Engine
class RPSGame
  attr_accessor :human, :computer

  def initialize
    @human = Human.new
    @computer = Computer.new
  end

  def display_welcome_message
    puts "Welcome to Rock, Paper, Scissors!"
  end

  def display_goodbye_message
    puts "Thanks for playing Rock, Paper, Scissors. Good bye!"
  end

  def display_moves
    puts "#{human.name} chose #{human.move}"
    puts "#{computer.name} chose #{computer.move}"
  end

  def display_winner
    if human.move > computer.move
      puts "#{human.name} won!"
    elsif human.move < computer.move
      puts "#{computer.name} won!"
    else
      puts "It's a tie!"
    end
  end

  def display_move_history
    puts "#{human.name}'s move history:"
    human.move_history.each_with_index do |mv, index|
      puts "#{index + 1}: #{mv}"
    end
    puts "#{computer.name}'s move history:"
    computer.move_history.each_with_index do |mv, index|
      puts "#{index + 1}: #{mv}"
    end
  end

  def improve_computer
    if computer.move > human.move
      computer.update_smart_choices(:win)
    elsif computer.move < human.move
      computer.update_smart_choices(:loss)
    end
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp
      break if ['y', 'n'].include? answer.downcase
      puts "Sorry, must be y or n."
    end
    return false if answer.downcase == 'n'
    return true if answer.downcase == 'y'
  end

  def play
    display_welcome_message
    loop do
      human.choose
      human.remember_move
      computer.choose
      computer.remember_move
      display_moves
      display_winner
      display_move_history
      improve_computer
      break unless play_again?
    end
    display_goodbye_message
  end
end

RPSGame.new.play
