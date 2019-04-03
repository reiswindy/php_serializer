require "./object"

struct PHP::Any
  # Possible serialization types.
  alias Type = Nil | Bool | Int64 | Float64 | String | Hash(String|Int64, PHP::Any) | PHP::Object

  getter raw : Type

  def initialize(@raw : Type)
  end

  def initialize(any : Any)
    @raw = any.raw
  end

  def size : Int32
    case object = @raw
    when Hash
      object.size
    else
      raise "Expected Hash for #size, not #{object.class}"
    end
  end

  def [](key : Int | String) : PHP::Any
    case object = @raw
    when Hash
      if key.is_a?(Int)
        PHP::Any.new(object[key.to_i64])
      else
        PHP::Any.new(object[key])
      end
    else
      raise "Expected Hash for #[](key : Int | String), not #{object.class}"
    end
  end

  def []?(key : Int | String) : PHP::Any?
    case object = @raw
    when Hash
      if key.is_a?(Int)
        PHP::Any.new(object[key.to_i64]) if object[key.to_i64]?
      else
        PHP::Any.new(object[key]) if object[key]?
      end
    else
      raise "Expected Hash for #[]?(key : Int | String), not #{object.class}"
    end
  end

  #TODO: dig, dig?

  def as_nil : Nil
    @raw.as(Nil)
  end

  def as_bool : Bool
    @raw.as(Bool)
  end

  def as_bool? : Bool?
    as_bool if @raw.is_a?(Bool)
  end

  def as_i : Int32
    @raw.as(Int).to_i32
  end

  def as_i? : Int32
    as_i if @raw.is_a?(Int)
  end

  def as_i64 : Int64
    @raw.as(Int).to_i64
  end

  def as_i64? : Int64?
    as_i64 if @raw.is_a?(Int)
  end

  def as_f : Float64
    @raw.as(Float).to_f
  end

  def as_f? : Float64?
    as_f if @raw.is_a?(Float64)
  end

  def as_f32 : Float32
    @raw.as(Float).to_f32
  end

  def as_f32? : Float32?
    as_f32 if @raw.is_a?(Float32) || @raw.is_a?(Float64)
  end

  def as_s : String
    @raw.as(String)
  end

  def as_s? : String?
    as_s if @raw.is_a?(String)
  end

  def as_h : Hash(Int32|String, PHP::Any)
    @raw.as(Hash)
  end

  def as_h? : Hash(Int32|String, PHP::Any)?
    as_h if @raw.is_a?(Hash)
  end

  def as_o : PHP::Object
    @raw.as(PHP::Object)
  end

  def as_o? : PHP::Object?
    as_o if @raw.is_a?(PHP::Object)
  end

  delegate to_s, to: @raw
  delegate to_json, to: @raw
  delegate inspect, to: @raw
  delegate pretty_print, to: @raw

  def ==(other : PHP::Any)
    @raw == other.raw
  end

  def ==(other)
    @raw == other
  end
end