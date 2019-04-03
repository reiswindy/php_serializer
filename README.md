# php_serializer

Parse PHP serialized strings 

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  php_serializer:
    github: reiswindy/php_serializer
```

## Usage

```crystal
require "php_serializer"

# Parse string
parsed = PHP.parse(%(a:2:{i:0;i:27;s:5:"Hello";i:1;}))

parsed[0] == 27
parsed["Hello"] == 1

# Parse string with references
parsed = PHP.parse(%(a:3:{i:0;r:1;i:1;i:23;i:2;r:1;}))

parsed[1] == 23
parsed[0][1] == 23
parsed[2][0][1] == 23

# Parse string object
parsed = PHP.parse(%(O:8:"DateTime":3:{s:4:"date";s:26:"2019-03-30 01:33:48.000000";s:13:"timezone_type";i:3;s:8:"timezone";s:16:"America/New_York";}))

parsed.class_name == "DateTime"
parsed["date"] == "2019-03-30 01:33:48.000000"
parsed["timezone_type"] == 3
parsed["timezone"] == "America/New_York"
```

## Contributing

1. Fork it ( https://github.com/reiswindy/php_serializer/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [reiswindy](https://github.com/reiswindy) - creator, maintainer
