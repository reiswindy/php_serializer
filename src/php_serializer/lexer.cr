abstract class PHP::Lexer
  property token : PHP::Token

  def self.new(string : String)
    StringBased.new(string)
  end

  def self.new(io : IO)
    IOBased.new(io)
  end

  def initialize
    @column_number = 1
    @token = PHP::Token.new
    @buffer = IO::Memory.new
  end

  abstract def current_char
  abstract def next_char_no_column_increment

  abstract def internal_consume_string(bytesize : Int64)
  abstract def number_start
  abstract def append_number_char
  abstract def number_string

  def next_token
    @token.column_number = @column_number
    
    case current_char
    when '\0'
      @token.type = :EOF
    when 'N'
      consume_null
    when 'b'
      consume_bool
    when 'i'
      consume_integer
    when 'd'
      consume_float
    when 's'
      consume_string
    when 'r'
      consume_reference
    when 'R'
      consume_reference
    when 'a'
      consume_begin_hash
    when 'O'
      consume_begin_object
    when '}'
      unexpected_character if @column_number == 1
      consume_end_hash_or_object
    else
      unexpected_character
    end
  end

  def next_char
    @column_number += 1
    next_char_no_column_increment
  end

  def consume_null
    unexpected_character if next_char != ';'
    @token.type = :null
    next_char
  end

  def consume_bool
    unexpected_character if next_char != ':'
    char = next_char
    unexpected_character if char != '1' && char != '0'
    unexpected_character if next_char != ';'
    @token.type = (char == '1') ? :true : :false
    next_char
  end

  def consume_string
    unexpected_character if next_char != ':'
    next_char

    expected_bytesize = internal_consume_integer
    unexpected_character if current_char != ':'
    next_char

    string = internal_consume_string(expected_bytesize)
    unexpected_character if current_char != ';'

    actual_bytesize = string.bytesize
    raise_error("Expected a string of #{expected_bytesize} bytes, got #{actual_bytesize} bytes") if expected_bytesize != actual_bytesize

    @token.type = :string
    @token.string_value = string
    next_char
  end

  def consume_integer
    unexpected_character if next_char != ':'
    next_char

    integer = internal_consume_integer
    unexpected_character if current_char != ';'

    @token.type = :int
    @token.int_value = integer
    next_char
  end

  def consume_float
    unexpected_character if next_char != ':'
    next_char

    float = internal_consume_float
    unexpected_character if current_char != ';'

    @token.type = :float
    @token.float_value = float
    next_char
  end

  def consume_reference
    unexpected_character if next_char != ':'
    next_char

    index = internal_consume_integer
    unexpected_character if current_char != ';'

    @token.type = :reference
    @token.int_value = index
    next_char
  end

  def consume_begin_hash
    unexpected_character if next_char != ':'
    next_char

    size = internal_consume_integer
    unexpected_character if current_char != ':'
    unexpected_character if next_char != '{'

    @token.type = :begin_hash
    @token.nested_elements = size
    next_char
  end
    
  def consume_begin_object
    unexpected_character if next_char != ':'
    next_char

    bytesize = internal_consume_integer
    unexpected_character if current_char != ':'
    next_char

    name = internal_consume_string(bytesize)
    unexpected_character if current_char != ':'
    next_char

    size = internal_consume_integer
    unexpected_character if current_char != ':'
    unexpected_character if next_char != '{'

    @token.type = :begin_object
    @token.nested_elements = size
    @token.object_class_name = name
    next_char
  end

  def consume_end_hash_or_object
    @token.type = :end_hash_or_object
    next_char    
  end

  private def internal_consume_integer
    negative = false
    integer = 0_i64

    if current_char == '-'
      negative = true
      next_char
    end

    case current_char
    when '0'
      next_char
    when '1'..'9'
      integer += current_char - '0'
      char = next_char
      while '0' <= char <= '9'
        integer *= 10
        integer += current_char - '0'
        char = next_char
      end
    else
      unexpected_character
    end
    integer = (-integer) if negative
    integer    
  end

  private def internal_consume_float
    number_start

    negative = false
    integer = 0_i64
    divisor = 1_i64
    digits = 1

    if current_char == '-'
      negative = true
      next_char
    end

    case current_char
    when '0'
      append_number_char
      char = next_char
      unexpected_character if char != '.'
      append_number_char
      char = next_char
      unexpected_character unless '0' <= char <= '9'
      while '0' <= char <= '9'
        append_number_char
        integer *= 10
        integer += char - '0'
        divisor *= 10
        digits += 1
        char = next_char
      end
    when '1'..'9'
      append_number_char
      integer += current_char - '0'
      char = next_char
      while '0' <= char <= '9'
        append_number_char
        integer *= 10
        integer += char - '0'
        digits += 1
        char = next_char
      end
      unexpected_character if char != '.'
      append_number_char
      char = next_char
      unexpected_character unless '0' <= char <= '9'
      while '0' <= char <= '9'
        append_number_char
        integer *= 10
        integer += char - '0'
        divisor *= 10
        digits += 1
        char = next_char
      end
    else
      unexpected_character
    end

    float = integer.to_f64 / divisor
    if digits >= 18
      float = number_string.to_f64
    else
      float = (-float) if negative
    end
    float
  end

  def unexpected_character
    raise_error("Unexpected character '#{current_char}' in column '#{@column_number}'")
  end

  def raise_error(msg)
    raise PHP::ParseException.new(msg)
  end
end