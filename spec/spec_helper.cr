require "spec"
require "../src/php_serialize"

class SimpleTestClass
  include PHP::Serializable
  @value = 25
  @another_value = "Zapato"
  property better : BetterTestClass?
end

class BetterTestClass
  include PHP::Serializable
  @value = [50]
  property simple : SimpleTestClass?
end