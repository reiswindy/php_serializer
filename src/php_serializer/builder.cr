class PHP::Builder

  record StartState
  record StartDocumentState
  record ArrayState, valid_size : Int32, size_used : Int32, index : Bool
  record ObjectState, valid_size : Int32, size_used : Int32, name : Bool
  record EndDocumentState

  alias State = StartState | StartDocumentState | ArrayState | ObjectState | EndDocumentState

  def initialize(@io : IO)
    @items_parsed = 0
    @references = {} of UInt64 => Int32
    @state = [StartState.new] of State
  end

  def document
    start_document
    yield.tap { end_document }
  end

  private def start_document
    case state = @state.last
    when StartState
      @state[-1] = StartDocumentState.new
    when EndDocumentState
      @state[-1] = StartDocumentState.new
    else
      raise PHP::Error.new("Starting new document before finishing previous one.")
    end
  end

  private def end_document
    case state = @state.last
    when StartState
      raise PHP::Error.new("Empty string.")
    when StartDocumentState
      raise PHP::Error.new("Empty string.")
    when ArrayState
      raise PHP::Error.new("Unterminated array.")
    when ObjectState
      raise PHP::Error.new("Unterminated object.")
    end
    @references.clear
    @items_parsed = 0
    nil
  end

  def array(size : Int32)
    start_array(size)
    yield.tap { end_array }
  end

  private def start_array(size : Int32)
    start_scalar
    @state.push(ArrayState.new(valid_size: size, size_used: 0, index: true))
    @io << "a:#{size}:{"
  end

  private def end_array
    case state = @state.last
    when ArrayState
      raise PHP::Error.new("Missing element value.") unless state.index
      raise PHP::Error.new("Invalid number of elements defined for this array.") unless state.valid_size == state.size_used
      @state.pop
    else
      raise PHP::Error.new("Not inside an array.")
    end
    @io << "}"
    end_scalar
  end

  def object(object, size : Int32)
    new_object = true
    
    if object.is_a?(Reference) && @references.has_key?(object.object_id)
      new_object = false
    end

    if new_object
      start_object(object.class, size)
      if object.is_a?(Reference)
        @references[object.object_id] = @items_parsed 
      end
      yield.tap { end_object }
    else
      scalar do
        item_number = @references[object.object_id]
        @io << "r:#{item_number};"
      end
    end
  end

  private def start_object(klass : Class, size : Int32)
    start_scalar
    @state.push(ObjectState.new(valid_size: size, size_used: 0, name: true))
    @io << %(O:#{klass.to_s.size}:"#{klass.to_s}":#{size}:{)
  end

  private def end_object
    case state = @state.last
    when ObjectState
      raise PHP::Error.new("Missing property value.") unless state.name
      raise PHP::Error.new("Invalid number of properties defined for this object.") unless state.valid_size == state.size_used
      @state.pop
    else
      raise PHP::Error.new("Not inside an object.")
    end
    @io << "}"
    end_scalar
  end

  def indexed_value(key, value)
    key.to_php_serialized(self)
    value.to_php_serialized(self)
  end
  
  def indexed_value(key)
    key.to_php_serialized(self)
    yield
  end

  def named_property(name, value)
    name.to_php_serialized(self)
    value.to_php_serialized(self)    
  end

  def named_property(name)
    name.to_php_serialized(self)
    yield
  end

  private def scalar(string = false, int = false)
    start_scalar(string, int)
    yield.tap { end_scalar }
  end

  private def start_scalar(string = false, int = false)
    @items_parsed += 1
    case state = @state.last
    when StartState
      raise PHP::Error.new("Writing value before starting document.")
    when EndDocumentState
      raise PHP::Error.new("Writing after finishing document, but before starting new document.")
    when ArrayState
      if state.index && !string && !int
        raise PHP::Error.new("Key for array must be either a string or an integer")
      end
      @items_parsed -= 1 unless state.index
    when ObjectState
      if state.name && !string
        raise PHP::Error.new("Property name must be a string.")
      end
      @items_parsed -= 1 unless state.name
    end
  end

  private def end_scalar
    case state = @state.last
    when StartDocumentState
      @state[-1] = EndDocumentState.new
    when ArrayState
      size_used = state.size_used
      size_used += 1 unless state.index
      @state[-1] = ArrayState.new(state.valid_size, size_used, !state.index)
    when ObjectState
      size_used = state.size_used
      size_used += 1 unless state.name
      @state[-1] = ObjectState.new(state.valid_size, size_used, !state.name)
    end
  end

  def bool(value : Bool)
    scalar do
      @io << "b:#{value.to_unsafe};"      
    end
  end

  def null
    scalar do
      @io << "N;"
    end
  end

  def string(value : String)
    scalar(string: true) do
      @io << %(s:#{value.size}:"#{value}";)
    end
  end

  def int(value : Int)
    scalar(int: true) do
      @io << "i:#{value};"
    end
  end

  def float(value : Float)
    scalar do
      @io << "d:#{value};"
    end
  end

end

module PHP
  
  def self.build
    String.build do |str|
      build(str) do |php|
        yield php
      end
    end
  end

  def self.build(io : IO)
    builder = PHP::Builder.new(io)
    builder.document do
      yield builder
    end
  end

end
