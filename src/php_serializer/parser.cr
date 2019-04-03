class PHP::Parser
  
  def initialize(input : String | IO)
    @lexer = PHP::Lexer.new(input)
    @parsed_values = [] of Any
    next_token
  end

  def parse : Any
    value = parse_value
    expect_type(:EOF)
    value
  end

  private def parse_hash
    nested_elements = token.nested_elements

    hash = {} of Int64 | String => Any
    add_to_parsed_array(Any.new(hash))
    
    next_token
    nested_elements.times do
      key = parse_hash_key
      value = parse_value
      hash[key] = value

      add_to_parsed_array(value)
    end

    unexpected_token if token.type != :end_hash_or_object

    next_token
    Any.new(hash)
  end

  private def parse_hash_key
    case token.type
    when :string
      parse_value.as_s
    when :int
      parse_value.as_i64
    else
      unexpected_token
    end
  end

  private def parse_object
    nested_elements = token.nested_elements
    object_class_name = token.object_class_name

    obj = PHP::Object.new(object_class_name)
    add_to_parsed_array(Any.new(obj))

    next_token
    nested_elements.times do
      key = parse_object_key
      value = parse_value
      obj[key] = value

      add_to_parsed_array(value)
    end

    unexpected_token if token.type != :end_hash_or_object

    next_token
    Any.new(obj)
  end

  private def parse_object_key
    unexpected_token if token.type != :string
    parse_value.as_s
  end

  private def parse_reference
    reference_index = token.int_value.to_i - 1
    invalid_reference if reference_index < 0

    referenced_value = @parsed_values[reference_index]?
    invalid_reference if !referenced_value

    referenced_value.tap { next_token }
  end

  private def parse_value
    case token.type
    when :null
      Any.new(nil).tap { next_token }
    when :true
      Any.new(true).tap { next_token }
    when :false
      Any.new(false).tap { next_token }
    when :int
      Any.new(token.int_value).tap { next_token }
    when :float
      Any.new(token.float_value).tap { next_token }
    when :string
      Any.new(token.string_value).tap { next_token }
    when :begin_hash
      parse_hash
    when :begin_object
      parse_object
    when :reference
      parse_reference
    else 
      unexpected_token
    end
  end

  private def add_to_parsed_array(value)
    @parsed_values << value
  end

  private def expect_type(token_type)
    unexpected_token unless token.type == token_type
  end

  private def unexpected_token
    raise_error("Unexpected token #{token.type} at #{token.column_number}")
  end

  private def invalid_reference
    raise_error("Invalid reference #{token.int_value} at #{token.column_number}")
  end

  private def raise_error(msg)
    raise PHP::ParseException.new(msg)
  end
  
  delegate token, to: @lexer
  delegate next_token, to: @lexer
end