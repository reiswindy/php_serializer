class PHP::Lexer::IOBased < PHP::Lexer
  def initialize(@io : IO)
    super()
    @current_char = @io.read_char || '\0'
  end

  def current_char
    @current_char
  end

  def next_char_no_column_increment
    @current_char = @io.read_char || '\0'
  end

  def number_start
    @buffer.clear
  end

  def append_number_char
    @buffer << current_char
  end

  def number_string
    @buffer.to_s
  end

  private def internal_consume_string(bytesize : Int64)
    unexpected_character if current_char != '"'
    string = @io.gets(bytesize)
    raise_error("Unexpected EOF") if !string
    unexpected_character if next_char != '"'
    next_char
    string
  end
end