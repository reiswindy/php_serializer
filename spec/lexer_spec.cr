require "./spec_helper"

describe PHP::Lexer::StringBased do
  
  it "consumes null token" do
    lexer = PHP::Lexer::StringBased.new("N;")
    lexer.next_token

    lexer.token.type.should eq(:null)
  end

  it "consumes bool token" do
    true_lexer = PHP::Lexer::StringBased.new("b:1;")
    true_lexer.next_token
    false_lexer = PHP::Lexer::StringBased.new("b:0;")
    false_lexer.next_token

    true_lexer.token.type.should eq(:true)
    false_lexer.token.type.should eq(:false)
  end

  it "consumes int token" do
    lexer = PHP::Lexer::StringBased.new("i:20034;")
    lexer.next_token

    lexer.token.type.should eq(:int)
    lexer.token.int_value.should eq(20034)
  end

  it "consumes float token" do
    lexer = PHP::Lexer::StringBased.new("d:34.354;")
    lexer.next_token

    lexer.token.type.should eq(:float)
    lexer.token.float_value.should eq(34.354)
  end

  it "consumes LARGE float token" do
    lexer = PHP::Lexer::StringBased.new("d:34.35499999999987651;")
    lexer.next_token

    lexer.token.type.should eq(:float)
    lexer.token.float_value.should eq(34.35499999999987651)
  end

  it "consumes string token" do
    lexer = PHP::Lexer::StringBased.new(%(s:14:"Añaños' Crib";))
    lexer.next_token

    lexer.token.type.should eq(:string)
    lexer.token.string_value.should eq("Añaños' Crib")
  end

  it "consumes reference token" do
    lexer = PHP::Lexer::StringBased.new(%(r:14;))
    lexer.next_token

    lexer.token.type.should eq(:reference)
    lexer.token.int_value.should eq(14)
  end

  it "consumes begin_hash token" do
    lexer = PHP::Lexer::StringBased.new(%(a:2:{i:0;i:10;i:1;s:4:"hola";}))
    lexer.next_token

    lexer.token.type.should eq(:begin_hash)
    lexer.token.nested_elements.should eq(2)
  end

  it "consumes begin_object token" do
    lexer = PHP::Lexer::StringBased.new(%(O:8:"DateTime":3:{s:4:"date";s:26:"2019-03-30 01:33:48.000000";s:13:"timezone_type";i:3;s:8:"timezone";s:16:"America/New_York";}))
    lexer.next_token

    lexer.token.type.should eq(:begin_object)
    lexer.token.nested_elements.should eq(3)
    lexer.token.object_class_name.should eq("DateTime")
  end

end

describe PHP::Lexer::IOBased do
  
  it "consumes null token" do
    io = IO::Memory.new("N;")
    lexer = PHP::Lexer::IOBased.new(io)
    lexer.next_token

    lexer.token.type.should eq(:null)
  end

  it "consumes bool token" do
    io = IO::Memory.new("b:1;")
    true_lexer = PHP::Lexer::IOBased.new(io)
    true_lexer.next_token
    io = IO::Memory.new("b:0;")
    false_lexer = PHP::Lexer::IOBased.new(io)
    false_lexer.next_token

    true_lexer.token.type.should eq(:true)
    false_lexer.token.type.should eq(:false)
  end

  it "consumes int token" do
    io = IO::Memory.new("i:20034;")
    lexer = PHP::Lexer::IOBased.new(io)
    lexer.next_token

    lexer.token.type.should eq(:int)
    lexer.token.int_value.should eq(20034)
  end

  it "consumes float token" do
    io = IO::Memory.new("d:34.354;")
    lexer = PHP::Lexer::IOBased.new(io)
    lexer.next_token

    lexer.token.type.should eq(:float)
    lexer.token.float_value.should eq(34.354)
  end

  it "consumes LARGE float token" do
    io = IO::Memory.new("d:34.35499999999987651;")
    lexer = PHP::Lexer::IOBased.new(io)
    lexer.next_token

    lexer.token.type.should eq(:float)
    lexer.token.float_value.should eq(34.35499999999987651)
  end

  it "consumes string token" do
    io = IO::Memory.new(%(s:14:"Añaños' Crib";))
    lexer = PHP::Lexer::IOBased.new(io)
    lexer.next_token

    lexer.token.type.should eq(:string)
    lexer.token.string_value.should eq("Añaños' Crib")
  end

  it "consumes reference token" do
    io = IO::Memory.new(%(r:14;))
    lexer = PHP::Lexer::IOBased.new(io)
    lexer.next_token

    lexer.token.type.should eq(:reference)
    lexer.token.int_value.should eq(14)
  end

  it "consumes begin_hash token" do
    io = IO::Memory.new(%(a:2:{i:0;i:10;i:1;s:4:"hola";}))
    lexer = PHP::Lexer::IOBased.new(io)
    lexer.next_token

    lexer.token.type.should eq(:begin_hash)
    lexer.token.nested_elements.should eq(2)
  end

  it "consumes begin_object token" do
    io = IO::Memory.new(%(O:8:"DateTime":3:{s:4:"date";s:26:"2019-03-30 01:33:48.000000";s:13:"timezone_type";i:3;s:8:"timezone";s:16:"America/New_York";}))
    lexer = PHP::Lexer::IOBased.new(io)
    lexer.next_token

    lexer.token.type.should eq(:begin_object)
    lexer.token.nested_elements.should eq(3)
    lexer.token.object_class_name.should eq("DateTime")
  end
end