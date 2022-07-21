dict_path = File.join(File.dirname(__FILE__), '../assets/dictionary.txt')
$file_in = File.read(dict_path).split("\n")

$pics_path = File.join(File.dirname(__FILE__), '../assets/hang_7height.txt')
$pics_in = File.read($pics_path).split("\n")

module ReadASCII
  def ascii_slice(_file_path, frame_height)
    
    frame_count = $pics_in.length / frame_height
    @frames = []

    for i in 0...frame_count
      @frames.push($pics_in[0...frame_height])
      for i in 0...frame_count
        $pics_in.shift
      end
    end
  end
end

class Hangman
  include ReadASCII
  def initialize
    @dictionary = $file_in.each_with_object([]) do |value, list|
      list.push(value) if value.length.between?(5, 12)
    end

    ascii_slice($pics_path, 7)

    put_title

    new_game
  end

  def new_game
    @bad_guesses = 0

    new_words
    puts @frames[0]
    puts @working_word.join(" ")

    while @bad_guesses < 6 do
      new_guess
      if @working_word == @secret_word
        win_game
        win = true
      end      
    end
    if !win 
      lose_game
    end
    ask_new_game
  end

  def win_game
    puts "You won!"
    puts "#{@working_word.join} was correct!"
    puts "Start a new game? y/n"
    input = gets.chomp.downcase
    if input == 'y'
      new_game
    else
      puts "Thanks for playing"
      put_title
      exit(0)
    end
  end

  def lose_game
    puts "Sorry you were hung!"
    puts "The secret word was #{@secret_word.join}"
    puts "Start a new game? y/n"
    input = gets.chomp.downcase
    if input == 'y'
      new_game
    else
      puts "Thanks for playing"
      put_title
      exit(0)
    end
  end

  def new_guess
    puts "Guess a letter: "
    input = gets.chomp.downcase
    correct = false

    @secret_word.each_with_index do |letter,dex|
      if input == letter
        @working_word[dex] = input
        correct = true
      end
    end
    if !correct
      @bad_guesses += 1
    end
    puts @frames[@bad_guesses]
    puts @working_word.join(" ")
  end

  def new_words
    @secret_word = @dictionary[Random.rand(@dictionary.length - 1)].split('')
    @working_word = []
    for i in @secret_word
      @working_word.push("_")
    end
  end
  
  def put_title
    puts "\n  /\\  /\\  __ _  _ __    __ _          /\\/\\    __ _  _ __  "
    puts " / /_/ / / _` || '_ \\  / _` | _____  /    \\  / _` || '_ \\ "
    puts '/ __  / | (_| || | | || (_| ||_____|/ /\\/\\ \\| (_| || | | |'
    puts '\\/ /_/   \\__,_||_| |_| \\__, |       \\/    \\/ \\__,_||_| |_|'
    puts '                       |___/                              '
  end
end

dic = Hangman.new