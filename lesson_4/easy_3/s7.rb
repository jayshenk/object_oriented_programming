# The self.information method does not add any value. We can make it valuable by 
# changing it to an instance method that uses its attributes like so:

class Light
  attr_accessor :brightness, :color

  def initialize(brightness, color)
    @brightness = brightness
    @color = color
  end

  def information
    "I want to turn on the light with a brightness level of #{brightness} and a colour of #{color}"
  end
end

bulb = Light.new("high", "yellow")
puts bulb.information
