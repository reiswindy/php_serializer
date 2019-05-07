# php_serializer

Parse PHP serialized strings and serialize objects as PHP strings

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  php_serializer:
    github: reiswindy/php_serializer
```

## Interface
* `PHP.parse(input : String | IO) : PHP::Any`
* `PHP::Any` holds the parsed value. Use with `.as_nil`, `.as_bool`, `.as_i`, `.as_f`, `.as_s`, `.as_h`, `.as_o`
* `PHP::Object` holds information about a parsed object

## Usage
```crystal
require "php_serializer"
```

### Parse array string
```crystal
parsed = PHP.parse(%(a:2:{i:0;i:27;s:5:"Hello";i:1;}))

parsed[0].as_i       # => 27
parsed["Hello"].as_i # => 1
```

### Parse string with references
```crystal
parsed = PHP.parse(%(a:3:{i:0;r:1;i:1;i:23;i:2;r:1;}))

parsed[1].as_i       # => 23
parsed[0][1].as_i    # => 23
parsed[2][0][1].as_i # => 23
```

### Parse object string
```crystal
parsed = PHP.parse(%(O:8:"DateTime":3:{s:4:"date";s:26:"2019-03-30 01:33:48.000000";s:13:"timezone_type";i:3;s:8:"timezone";s:16:"America/New_York";}))

obj = parsed.as_o
obj.class_name            # => "DateTime"
obj["date"].as_s          # => "2019-03-30 01:33:48.000000"
obj["timezone_type"].as_i # => 3
obj["timezone"].as_s      # => "America/New_York"
```

### Make a class serializable
```crystal
class Menino
  include PHP::Serializable

  def initialize(@name : String, @age : Int32)
  end
end

menino = Menino.new("Joel", 6)
menino.to_php_serialized # => "O:6:\"Menino\":2:{s:4:\"name\";s:4:\"Joel\";s:3:\"age\";i:6;}"
```

## Contributing

1. Fork it ( https://github.com/reiswindy/php_serializer/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [reiswindy](https://github.com/reiswindy) - creator, maintainer
