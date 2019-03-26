class PHP::Object
  getter class_name
  getter properties
  
  def initialize(@class_name : String)
    @properties = {} of String => Any
  end

  def [](key : String)
    @properties[key]
  end

  def []?(key : String)
    @properties[key]?
  end

  def []=(key : String, value : PHP::Any)
    @properties[key] = value
  end

  def ==(other : self)
    @class_name == other.class_name && @properties == other.properties
  end

  delegate to_json, to: @properties
end