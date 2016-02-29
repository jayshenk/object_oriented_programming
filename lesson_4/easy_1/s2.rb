# include the module in the Car and Truck classes

module Speed
  def go_fast
    puts "I am a #{self.class} and going super fast!"
  end
end

class Car
  include Speed

  def go_slow
    puts "I am safe and driving slow."
  end
end

class Truck
  include Speed
  def go_very_slow
    puts "I am a heavy truck and like going very slow."
  end
end

honda = Car.new
ford = Truck.new

# Confirm that Car and Truck can go fast
honda.go_fast
ford.go_fast
