class Object
  def to_php_serialized
    String.build do |str|
      to_php_serialized(str)
    end
  end

  def to_php_serialized(io : IO)
    PHP.build(io) do |php|
      to_php_serialized(php)
    end
  end
end

struct Nil
  def to_php_serialized(php : PHP::Builder)
    php.null
  end
end

struct Bool
  def to_php_serialized(php : PHP::Builder)
    php.bool(self)
  end
end

struct Int
  def to_php_serialized(php : PHP::Builder)
    php.int(self)
  end
end

struct Float
  def to_php_serialized(php : PHP::Builder)
    php.float(self)
  end
end

class String
  def to_php_serialized(php : PHP::Builder)
    php.string(self)
  end
end

struct Symbol
  def to_php_serialized(php : PHP::Builder)
    php.string(to_s)
  end
end

class Array
  def to_php_serialized(php : PHP::Builder)
    php.array(size) do
      each_with_index do |value, index|
        php.indexed_value(index, value)
      end
    end
  end
end

struct Set
  def to_php_serialized(php : PHP::Builder)
    php.array(size) do
      each_with_index do |value, index|
        php.indexed_value(index, value)
      end
    end
  end
end

class Hash
  def to_php_serialized(php : PHP::Builder)
    php.array(size) do
      each do |key, value|
        php.indexed_value(key, value)
      end
    end
  end
end

struct Tuple
  def to_php_serialized(php : PHP::Builder)
    {% begin %}
      {% prop = [] of Nil %}
      {% for i in 0...T.size %}
        {% prop << i %}
      {% end %}
      php.array({{prop.size}}) do
        {% for i in 0...T.size %}
          php.indexed_value({{i}}, self[{{i}}])
        {% end %}
      end
    {% end %}
  end
end

struct NamedTuple
  def to_php_serialized(php : PHP::Builder)
    {% begin %}
      {% s = T.keys.size %}
      php.array({{s}}) do
        {% for key in T.keys %}
          php.indexed_value({{key.stringify}}, self[{{key.symbolize}}])
        {% end %}
      end
    {% end %}
  end
end
