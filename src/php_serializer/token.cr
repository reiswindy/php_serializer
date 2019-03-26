class PHP::Token
  property type : Symbol
  property int_value : Int64
  property float_value : Float64
  property string_value : String
  property column_number : Int32

  property object_class_name : String
  property nested_elements : Int64

  def initialize
    @type = :EOF
    @int_value = 0_i64
    @float_value = 0.0
    @string_value = ""
    @column_number = 0

    @nested_elements = 0
    @object_class_name = ""
  end
end