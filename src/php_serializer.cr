require "./php_serializer/**"

module PHP
  class ParseException < Exception
  end

  def self.parse(input : String | IO) : Any
    Parser.new(input).parse
  end
end
