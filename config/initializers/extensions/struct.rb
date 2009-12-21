#
# extensions/struct
#
# Add several methods to make a struct duck-type much more like a Hash
#
Struct.class_eval do
  include HashLike
  def self.keys
    members
  end
end


