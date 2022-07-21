require 'yaml'

dict_path = File.join(File.dirname(__FILE__), '../assets/dictionary.txt')
$file_in = File.read(dict_path).split("\n")

$pics_path = File.join(File.dirname(__FILE__), '../assets/hang_7height.txt')
$pics_in = File.read($pics_path).split("\n")

$save_path = File.join(File.dirname(__FILE__), '../save/save_file.yaml')
$save = YAML.load(File.read($save_path)) if File.file?($save_path)

module BasicSerializable
  @@serializer = YAML

  def serialize
    obj = {}
    instance_variables.map do |var|
      obj[var] = instance_variable_get(var) if var != :@dictionary
    end
    @@serializer.dump obj
  end

  def unserialize
    $save.keys.each do |key|
      instance_variable_set(key, $save[key])
    end
  end
end

class Hangman
  include BasicSerializable

  attr_accessor :frames, :bad_guesses, :chosen_bads, :secret_word, :working_word

  def initialize(frames = [], bad_guesses = 0, chosen_bads = [], secret_word = [], working_word = [])
    @dictionary = $file_in.each_with_object([]) do |value, list|
      list.push(value) if value.length.between?(5, 12)
    end
    @frames = frames
    @bad_guesses = bad_guesses
    @chosen_bads = chosen_bads
    @secret_word = secret_word
    @working_word = working_word
    ascii_slice(7)
  end

  #---  Game Controller Methods  ---#

  def put_title
    puts "\n  /\\  /\\  __ _  _ __    __ _          /\\/\\    __ _  _ __  "
    puts " / /_/ / / _` || '_ \\  / _` | _____  /    \\  / _` || '_ \\ "
    puts '/ __  / | (_| || | | || (_| ||_____|/ /\\/\\ \\| (_| || | | |'
    puts '\\/ /_/   \\__,_||_| |_| \\__, |       \\/    \\/ \\__,_||_| |_|'
    puts '                       |___/                              '
  end

  def save_notice
    puts "You can save your game anytime by entering the tilde '~' character as your guess\n"
  end

  def load_check
    if File.file?('save/save_file.yaml')
      puts 'Would you like to load your last game? y/n'
      input = gets.chomp.downcase
      input[0] == 'y'
    else
      false
    end
  end

  def load_game
    puts @frames[@bad_guesses]
    puts "Tried : #{@chosen_bads.join(' ')}\n"
    puts "Correct: #{@working_word.join(' ')}\n"
    new_guess
    while @bad_guesses < 6
      new_guess
      if @working_word == @secret_word
        win_game
        win = true
      end
    end
    lose_game unless win
    ask_new_game
  end

  def new_game
    @bad_guesses = 0
    @chosen_bads = []

    new_words
    puts @frames[0]
    puts "Tried : #{@chosen_bads.join(' ')}\n"
    puts "Correct: #{@working_word.join(' ')}\n"

    while @bad_guesses < 6
      new_guess
      if @working_word == @secret_word
        win_game
        win = true
      end
    end
    lose_game unless win
    ask_new_game
  end

  #---  Internal Methods  ---#
  private

  def win_game
    File.delete($save_path) if File.file?($save_path)
    puts 'You won!'
    puts "#{@working_word.join} was correct!"
    puts 'Start a new game? y/n'
    input = gets.chomp.downcase
    if input == 'y'
      new_game
    else
      puts 'Thanks for playing'
      put_title
      exit(0)
    end
  end

  def lose_game
    File.delete($save_path) if File.file?($save_path)
    puts 'Sorry you were hung!'
    puts "The secret word was #{@secret_word.join}"
    puts 'Start a new game? y/n'
    input = gets.chomp.downcase
    if input == 'y'
      new_game
    else
      puts 'Thanks for playing'
      put_title
      exit(0)
    end
  end

  def new_guess
    puts 'Guess a letter: '
    input = gets.chomp.downcase
    correct = false

    if input == '~'
      $save = File.open($save_path, 'w')
      $save.write(serialize)
      puts 'Game saved'
      exit(0)
    end

    @secret_word.each_with_index do |letter, dex|
      if input == letter
        @working_word[dex] = input
        correct = true
      end
    end
    unless correct
      @bad_guesses += 1
      @chosen_bads.push(input)
    end
    puts @frames[@bad_guesses]
    puts "Tried : #{@chosen_bads.join(' ')}\n"
    puts "Correct: #{@working_word.join(' ')}\n"
  end

  def new_words
    @secret_word = @dictionary[Random.rand(@dictionary.length - 1)].split('')
    @working_word = []
    for i in @secret_word
      @working_word.push('_')
    end
  end

  def ascii_slice(frame_height)
    frame_count = $pics_in.length / frame_height

    for i in 0...frame_count
      @frames.push($pics_in[0...frame_height])
      for i in 0...frame_count
        $pics_in.shift
      end
    end
  end
end
#--------------------------------------------------------------------->end Hangman

#--- Controller ---#
game = Hangman.new
game.put_title
game.save_notice

if game.load_check
  game.unserialize
  game.load_game
else
  game.new_game
end
