require "./spec_helper"

describe PHP::PullParser do

  it "reads null" do
    parser = PHP::PullParser.new("N;")
    parser.read_null.should eq(nil)
  end
    
  it "reads bools" do
    parser_true = PHP::PullParser.new("b:1;")
    parser_false = PHP::PullParser.new("b:0;")
    
    parser_true.read_bool.should eq(true)
    parser_false.read_bool.should eq(false)
  end

  it "reads ints" do
    parser = PHP::PullParser.new("i:20034;")
    parser.read_int.should eq(20034_i64)
  end

  it "reads floats" do
    parser = PHP::PullParser.new("d:34.354;")
    parser.read_float.should eq(34.354)
  end

  it "reads strings" do
    parser = PHP::PullParser.new(%(s:14:"Añaños' Crib";))
    parser.read_string.should eq("Añaños' Crib")
  end

  it "reads arbitrary type" do
    parser_n = PHP::PullParser.new("N;")
    parser_b = PHP::PullParser.new("b:1;")
    parser_i = PHP::PullParser.new("i:20034;")
    parser_f = PHP::PullParser.new("d:34.354;")
    parser_s = PHP::PullParser.new(%(s:14:"Añaños' Crib";))

    parser_n.read(Nil).should eq(nil)
    parser_b.read(Bool).should eq(true)
    parser_i.read(Int64).should eq(20034_i64)
    parser_f.read(Float64).should eq(34.354)
    parser_s.read(String).should eq("Añaños' Crib")
  end

  it "reads hash beginning data" do
    parser = PHP::PullParser.new(%(a:2:{i:0;s:4:"date";i:1;i:23;}))
    parser.read_begin_hash.should eq(2)
  end

  it "reads hash" do
    i = 0
    expected = [
      {0, String, "date"}, 
      {1, Int64, 23}, 
      {"date", String, "date"}
    ]

    parser = PHP::PullParser.new(%(a:3:{i:0;s:4:"date";i:1;i:23;s:4:"date";s:4:"date";}))        
    parser.read_hash do |key|
      expected_key, expected_class, expected_value = expected[i]
      value = parser.read(expected_class)

      key.should eq(expected_key)
      value.should eq(expected_value)
      i += 1
    end
  end

  it "reads object beginning data" do
    parser = PHP::PullParser.new(%(O:8:"DateTime":3:{s:4:"date";s:26:"2019-03-30 01:33:48.000000";s:13:"timezone_type";i:3;s:8:"timezone";s:16:"America/New_York";}))
    parser.read_begin_object.should eq({3, "DateTime"})
  end

  it "reads object" do
    i = 0
    expected = [
      {"date", String, "2019-03-30 01:33:48.000000"}, 
      {"timezone_type", Int64, 3}, 
      {"timezone", String, "America/New_York"}
    ]

    parser = PHP::PullParser.new(%(O:8:"DateTime":3:{s:4:"date";s:26:"2019-03-30 01:33:48.000000";s:13:"timezone_type";i:3;s:8:"timezone";s:16:"America/New_York";}))
    parser.read_object do |prop|
      expected_prop, expected_class, expected_value = expected[i]
      value = parser.read(expected_class)

      prop.should eq(expected_prop)
      value.should eq(expected_value)
      i += 1
    end
  end
end