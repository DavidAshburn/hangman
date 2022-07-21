dict_path = File.join(File.dirname(__FILE__), '../assets/dictionary.txt')
$file_in = File.read(dict_path).split("\n")

pics_path = File.join(File.dirname(__FILE__), '../assets/hang_7height.txt')
$pics_in = File.read(pics_path).split("\n")

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
    @secret_word = @dictionary[Random.rand(@dictionary.length - 1)]
  end
end

dic = Hangman.new

puts "\n  /\\  /\\  __ _  _ __    __ _          /\\/\\    __ _  _ __  "
puts " / /_/ / / _` || '_ \\  / _` | _____  /    \\  / _` || '_ \\ "
puts '/ __  / | (_| || | | || (_| ||_____|/ /\\/\\ \\| (_| || | | |'
puts '\\/ /_/   \\__,_||_| |_| \\__, |       \\/    \\/ \\__,_||_| |_|'
puts '                       |___/                              '

dic.ascii_slice(pics_path, 7)
