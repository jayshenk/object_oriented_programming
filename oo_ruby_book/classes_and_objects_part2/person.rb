# We get this error because attr_reader only creates a getter method.
# When we try to reassign the name instance variable to "Bob", we need
# a setter method called name=. We can get this by changing attr_reader
# to attr_accessor or attr_writer if we don't intend to use the getter
# functionality.

class Person
  attr_accessor :name
  def initialize(name)
    @name = name
  end
end

bob = Person.new("Steve")
bob.name = "Bob"
