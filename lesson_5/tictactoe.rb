require 'pry'
class Board
  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] + # rows
                  [[1, 4, 7], [2, 5, 8], [3, 6, 9]] + # cols
                  [[1, 5, 9], [3, 5, 7]]              # diagonals

  def initialize
    @squares = {}
    reset
  end

  def [](num)
    @squares[num]
  end

  def []=(num, marker)
    @squares[num].marker = marker
  end

  def unmarked_keys
    @squares.keys.select { |key| @squares[key].unmarked? }
  end

  def full?
    unmarked_keys.empty?
  end

  def someone_won?
    !!winning_marker
  end

  def winning_marker
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      if three_identical_markers?(squares)
        return squares.first.marker
      end
    end
    nil
  end

  def find_at_risk_square(marker)
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      marked_squares = squares.select { |square| square.marker == marker }
      unmarked_squares = squares.select { |square| square.unmarked? }
      if marked_squares.count == 2 && unmarked_squares.count == 1
        return @squares.select { |num, square| line.include?(num) && square.unmarked? }.keys.first
      end
    end
    nil
  end

  def reset
    (1..9).each { |key| @squares[key] = Square.new }
  end

  # rubocop:disable Metrics/AbcSize
  def draw
    puts "     |     |"
    puts "  #{@squares[1]}  |  #{@squares[2]}  |  #{@squares[3]}"
    puts "     |     |"
    puts "-----|-----|-----"
    puts "     |     |"
    puts "  #{@squares[4]}  |  #{@squares[5]}  |  #{@squares[6]}"
    puts "     |     |"
    puts "-----|-----|-----"
    puts "     |     |"
    puts "  #{@squares[7]}  |  #{@squares[8]}  |  #{@squares[9]}"
    puts "     |     |"
  end
  # rubocop:enable Metrics/AbcSize

  private

  def three_identical_markers?(squares)
    markers = squares.select(&:marked?).collect(&:marker)
    return false if markers.size != 3
    markers.min == markers.max
  end
end

class Square
  INITIAL_MARKER = " "

  attr_accessor :marker

  def initialize(marker=INITIAL_MARKER)
    @marker = marker
  end

  def to_s
    @marker
  end

  def unmarked?
    marker == INITIAL_MARKER
  end

  def marked?
    marker != INITIAL_MARKER
  end
end

class Player
  attr_accessor :score, :name
  attr_reader :marker

  def initialize(marker)
    @marker = marker
    @score = 0
    set_name
  end
end

class Human < Player
  def set_name
    answer = nil
    loop do
      puts "What's your name?"
      answer = gets.chomp
      break unless answer.empty?
    end
    self.name = answer
  end
end

class Computer < Player
  def set_name
    self.name = ['R2D2', 'Hal', 'Chappie', 'Sonny', 'Number 5'].sample
  end
end

class TTTGame
  FIRST_TO_MOVE = 'X'

  attr_reader :board, :human, :computer

  def initialize
    @board = Board.new
    @human = Human.new(choose_marker)
    @computer = Computer.new(computer_choose_marker)
    @current_marker = FIRST_TO_MOVE
  end

  def choose_marker
    answer = nil
    loop do
      puts "Do you want to play as X or O?"
      answer = gets.chomp
      break if ['X', 'O'].include? answer
      puts "That is not a valid marker."
    end
    answer
  end

  def computer_choose_marker
    human.marker == 'X' ? 'O' : 'X'
  end

  def play
    clear
    display_welcome_message

    loop do
      display_board

      loop do
        current_player_moves
        break if board.someone_won? || board.full?
        clear_screen_and_display_board
      end

      display_result
      score_result
      display_score
      if overall_winner?
        display_overall_winner
        break
      end
      break unless play_again?
      reset
      display_play_again_message
    end

    display_goodbye_message
  end

  private

  def display_welcome_message
    puts "Welcome to Tic Tac Toe!"
    puts ""
  end

  def display_goodbye_message
    puts "Thanks for playing Tic Tac Toe! Goodbye!"
  end

  def clear_screen_and_display_board
    clear
    display_board
  end

  def display_board
    puts "#{human.name} is a #{human.marker}. #{computer.name} is a #{computer.marker}."
    puts ""
    board.draw
    puts ""
  end

  def joinor(arr, delimiter=', ', word='or')
    arr[-1] = "#{word} #{arr.last}" if arr.size > 1
    arr.join(delimiter)
  end

  def human_moves
    puts "Choose a square (#{joinor(board.unmarked_keys)}):"
    square = nil
    loop do
      square = gets.chomp.to_i
      break if board.unmarked_keys.include?(square)
      puts "Sorry, that's not a valid choice."
    end

    board[square] = human.marker
  end

  def computer_moves
    key = nil

    # offense first
    key = board.find_at_risk_square(computer.marker)

    # defense
    if !key
      key = board.find_at_risk_square(human.marker)
    end

    # pick key 5
    if !key
      if board[5].unmarked?
        key = 5
      end
    end

    # just pick a key
    if !key
      key = board.unmarked_keys.sample
    end

    board[key] = computer.marker
  end

  def current_player_moves
    if @current_marker == human.marker
      human_moves
      @current_marker = computer.marker
    else
      computer_moves
      @current_marker = human.marker
    end
  end

  def display_result
    clear_screen_and_display_board

    case board.winning_marker
    when human.marker
      puts "You won!"
    when computer.marker
      puts "Computer won!"
    else
      puts "It's a tie!"
    end
  end

  def display_overall_winner
    if human.score == 5
      puts "You are the overall winner!"
    else
      puts "The computer is the overall winner!"
    end
  end

  def score_result
    if board.winning_marker == human.marker
      human.score += 1
    elsif board.winning_marker == computer.marker
      computer.score += 1
    end        
  end

  def display_score
    puts "-----------------"
    puts "Player wins: #{human.score}"
    puts "Computer wins: #{computer.score}"
    puts "-----------------"
  end

  def overall_winner?
    human.score == 5 || computer.score == 5
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp.downcase
      break if %w(y n).include? answer
      puts "Sorry, must be y or n"
    end

    answer == 'y'
  end

  def clear
    system 'clear'
  end

  def reset
    board.reset
    @current_marker = FIRST_TO_MOVE
    clear
  end

  def display_play_again_message
    puts "Let's play again!"
    puts ""
  end
end

game = TTTGame.new
game.play
