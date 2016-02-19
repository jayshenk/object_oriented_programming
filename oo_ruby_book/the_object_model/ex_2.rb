# A module is a collection of behaviors that can be included in classes via mixins.
# A module allows us to group reusable code into one place. We use modules in our
# classes by using the include reserved word, followed by the module name. Modues
# are also used as a namespace.

module Routine
  def eat
    puts "It eats."
  end
end

class ZooAnimal
  include Routine
end

tiger = ZooAnimal.new
