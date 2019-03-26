require "./spec_helper"

describe PHP::Parser do
  it "parses null" do
    parser = PHP::Parser.new("N;")
    parser.parse.should eq(nil)
  end

  it "parses bools" do
    parser_true = PHP::Parser.new("b:1;")
    parser_false = PHP::Parser.new("b:0;")
    
    parser_true.parse.should eq(true)
    parser_false.parse.should eq(false)
  end

  it "parses ints" do
    parser = PHP::Parser.new("i:20034;")
    parser.parse.should eq(20034_i64)
  end

  it "parses floats" do
    parser = PHP::Parser.new("d:34.354;")
    parser.parse.should eq(34.354)
  end

  it "parses strings" do
    parser = PHP::Parser.new(%(s:14:"Añaños' Crib";))
    parser.parse.should eq("Añaños' Crib")
  end

  it "parses hashes" do
    expected = {} of Int64 | String => PHP::Any
    expected[0_i64] = PHP::Any.new("date")
    expected[1_i64] = PHP::Any.new(23_i64)

    parser = PHP::Parser.new(%(a:2:{i:0;s:4:"date";i:1;i:23;}))
    parser.parse.should eq(expected)
  end

  it "parses objects" do
    expected = PHP::Object.new("DateTime")
    expected["date"] = PHP::Any.new("2019-03-30 01:33:48.000000")
    expected["timezone_type"] = PHP::Any.new(3_i64)
    expected["timezone"] = PHP::Any.new("America/New_York")

    parser = PHP::Parser.new(%(O:8:"DateTime":3:{s:4:"date";s:26:"2019-03-30 01:33:48.000000";s:13:"timezone_type";i:3;s:8:"timezone";s:16:"America/New_York";}))
    parser.parse.should eq(expected)
  end

  it "parses nested structures" do
    nested_hash = {} of Int64 | String => PHP::Any
    nested_hash["created"] = PHP::Any.new("2019-04-02")
    nested_hash["description"] = PHP::Any.new("Happy April Fool's Day!")

    nested_object = PHP::Object.new("Test")
    nested_object["attr"] = PHP::Any.new("34")
    nested_object["test"] = PHP::Any.new(nested_hash)

    expected = PHP::Object.new("Test")
    expected["attr"] = PHP::Any.new("34")
    expected["test"] = PHP::Any.new(nested_object)

    parser = PHP::Parser.new(%(O:4:"Test":2:{s:4:"attr";s:2:"34";s:4:"test";O:4:"Test":2:{s:4:"attr";s:2:"34";s:4:"test";a:2:{s:7:"created";s:10:"2019-04-02";s:11:"description";s:23:"Happy April Fool's Day!";}}}))
    parser.parse.should eq(expected)
  end
end