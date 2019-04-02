class PHP::Lexer::StringBased < PHP::Lexer
  def initialize(string : String)
    super()
    @reader = Char::Reader.new(string)
    @number_pos = 0
  end

  def current_char
    @reader.current_char
  end
  
  def next_char_no_column_increment
    @reader.next_char
  end

  def number_start
    @number_pos = @reader.pos
  end

  def append_number_char
  end

  def number_string
    @reader.string[@number_pos..@reader.pos-1]
  end

  private def internal_consume_string(bytesize : Int64)
    unexpected_character if current_char != '"'
    next_char
    string = @reader.string.byte_slice(@reader.pos, bytesize)
    @reader.pos += bytesize
    unexpected_character if current_char != '"'
    next_char
    string
  end
end