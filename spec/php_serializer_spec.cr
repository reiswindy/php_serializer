require "./spec_helper"

describe PHP do

  it "serializes a string correctly" do
    serialized_string = "AHOY MATEY'S".to_php_serialized
    serialized_string.should eq(%(s:12:"AHOY MATEY'S";))
  end
  
  it "serializes integers correctly" do
    serialized_string = 16735.to_php_serialized
    serialized_string.should eq(%(i:16735;))
  end

  it "serializes floats correctly" do
    serialized_string = 25.5094.to_php_serialized
    serialized_string.should eq(%(d:25.5094;))
  end

  it "serializes bools correctly" do
    serialized_string = true.to_php_serialized
    serialized_string.should eq(%(b:1;))
  end

  it "serializes null correctly" do
    serialized_string = nil.to_php_serialized
    serialized_string.should eq(%(N;))
  end

  it "serializes simple arrays correctly" do
    serialized_string = [23, "Hello"].to_php_serialized
    serialized_string.should eq(%(a:2:{i:0;i:23;i:1;s:5:"Hello";}))
  end

  it "serializes slightly more complex arrays correctly" do
    serialized_string = [[[23], "Hi"], true, [] of Int32].to_php_serialized
    serialized_string.should eq(%(a:3:{i:0;a:2:{i:0;a:1:{i:0;i:23;}i:1;s:2:"Hi";}i:1;b:1;i:2;a:0:{}}))
  end

  it "serializes hashes with string keys and integer keys correctly" do
    serialized_string = {"value" => 23, 0 => {"key" => "Another value"}, "thingy" => [23]}.to_php_serialized
    serialized_string.should eq(%(a:3:{s:5:"value";i:23;i:0;a:1:{s:3:"key";s:13:"Another value";}s:6:"thingy";a:1:{i:0;i:23;}}))
  end

  it "serializes tuples as arrays correctly" do
    serialized_string = {[34], "This value is bad"}.to_php_serialized
    serialized_string.should eq(%(a:2:{i:0;a:1:{i:0;i:34;}i:1;s:17:"This value is bad";}))
  end

  it "serializes named tuples as associative arrays correctly" do
    serialized_string = {first: [34], second: "This value is bad"}.to_php_serialized
    serialized_string.should eq(%(a:2:{s:5:"first";a:1:{i:0;i:34;}s:6:"second";s:17:"This value is bad";}))
  end

  it "serializes objects correctly" do
    object = SimpleTestClass.new

    serialized_string = object.to_php_serialized
    serialized_string.should eq(%(O:15:"SimpleTestClass":3:{s:6:"better";N;s:5:"value";i:25;s:13:"another_value";s:6:"Zapato";}))
  end

  it "serializes objects inside objects correctly" do
    simple_object = SimpleTestClass.new
    better_object = BetterTestClass.new
    
    simple_object.better = better_object

    serialized_string = simple_object.to_php_serialized
    serialized_string.should eq(%(O:15:"SimpleTestClass":3:{s:6:"better";O:15:"BetterTestClass":2:{s:6:"simple";N;s:5:"value";a:1:{i:0;i:50;}}s:5:"value";i:25;s:13:"another_value";s:6:"Zapato";}))
  end 

  it "serializes objects with recursive properties correctly" do
    simple_object = SimpleTestClass.new
    better_object = BetterTestClass.new
    
    simple_object.better = better_object
    better_object.simple = simple_object

    serialized_string = simple_object.to_php_serialized
    serialized_string.should eq(%(O:15:"SimpleTestClass":3:{s:6:"better";O:15:"BetterTestClass":2:{s:6:"simple";r:1;s:5:"value";a:1:{i:0;i:50;}}s:5:"value";i:25;s:13:"another_value";s:6:"Zapato";}))
  end

end
