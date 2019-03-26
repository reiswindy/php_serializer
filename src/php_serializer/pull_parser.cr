require "./lexer"

class PHP::PullParser

  getter kind

  def initialize(input)
    @lexer = PHP::Lexer.new(input)
    @kind = :EOF
    @bool_value = false
    @int_value = 0_i64
    @float_value = 0.0
    @string_value = ""
    @raw_value = ""
    @object_stack = [] of Symbol
    @location = 0
    @object_class_name = ""
    @nested_elements = 0_i64

    next_token
    case token.type
    when :null
      @kind = :null
    when :true
      @kind = :bool
      @bool_value = true
    when :false
      @kind = :bool
      @bool_value = false
    when :int
      @kind = :int
      @int_value = token.int_value
    when :float
      @kind = :float
      @float_value = token.float_value
    when :string
      @kind = :string
      @string_value = token.string_value
    when :begin_hash
      begin_hash
    when :begin_object
      begin_object
    when :reference
      # TODO:
    else
      unexpected_token
    end
  end

  private def next_token
    @location = @lexer.token.column_number
    @lexer.next_token
    token
  end

  private def token
    @lexer.token
  end

  def read(cls : Nil.class)
    read_null
  end

  def read(cls : Bool.class)
    read_bool
  end

  def read(cls : Int64.class)
    read_int
  end

  def read(cls : Float64.class)
    read_float
  end

  def read(cls : String.class)
    read_string
  end

  def read_null
    expect_kind(:null)
    nil.tap { read_next }
  end

  def read_bool
    expect_kind(:bool)
    @bool_value.tap { read_next }
  end

  def read_int
    expect_kind(:int)
    @int_value.tap { read_next }
  end

  def read_float
    expect_kind(:float)
    @float_value.tap { read_next }
  end

  def read_string
    expect_kind(:string)
    @string_value.tap { read_next }
  end

  def read_hash
    size = read_begin_hash
    size.times do
      key = read_hash_key
      yield key
    end
    read_end_hash_or_object
  end

  def read_begin_hash
    expect_kind(:begin_hash)
    @nested_elements.tap { read_next }
  end

  def read_hash_key
    case @kind
    when :string
      read_string
    when :int
      read_int
    else
      unexpected_token
    end
  end

  def read_object
    size, class_name = read_begin_object
    size.times do
      prop_name = read_property_name
      yield prop_name
    end
    read_end_hash_or_object
  end

  def read_begin_object
    expect_kind(:begin_object)
    {@nested_elements, @object_class_name}.tap { read_next }
  end

  def read_property_name
    expect_kind(:string)
    read_string
  end

  def read_end_hash_or_object
    expect_kind(:end_hash_or_object)
    read_next
  end

  def read_next
    current_kind = @kind

    case token.type
    when :null
      @kind = :null
      next_token
    when :true
      @kind = :bool
      @bool_value = true
      next_token
    when :false
      @kind = :bool
      @bool_value = false
      next_token
    when :int
      @kind = :int
      @int_value = token.int_value
      next_token
    when :float
      @kind = :float
      @float_value = token.float_value
      next_token
    when :string
      @kind = :string
      @string_value = token.string_value
      next_token
    when :begin_hash
      begin_hash
    when :begin_object
      begin_object
    when :end_hash_or_object
      @kind = :end_hash_or_object
      unexpected_token unless @object_stack.pop?
      next_token
    when :reference
      @kind = :reference
      # TODO:
      next_token
    when :EOF
      @kind = :EOF
    else
      unexpected_token
    end
  end

  private def begin_hash
    @kind = :begin_hash
    @nested_elements = token.nested_elements

    @object_stack << :hash

    case next_token.type
    when :int, :string, :end_hash_or_object
    else
      unexpected_token
    end
  end

  private def begin_object
    @kind = :begin_object
    @nested_elements = token.nested_elements
    @object_class_name = token.object_class_name

    @object_stack << :object

    case next_token.type
    when :string, :end_hash_or_object
    else
      unexpected_token
    end
  end

  private def expect_kind(kind)
    unexpected_token unless kind == @kind
  end

  private def unexpected_token
    raise_error("Unexpected token #{token.type} at #{@location}")
  end

  private def raise_error(msg)
    raise PHP::ParseException.new(msg)
  end
end