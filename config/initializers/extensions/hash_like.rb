#
# A hashlike has to
#
# *
# * The arguments to your initializer should be the same as the keys, in order
#   If not, you must override #from_hash
#
#
module HashLike

  # List of possible keys --
  # delegates to the class
  def keys
    self.class.keys
  end

  #
  # Return a Hash containing only values for the given keys.
  #
  # Since this is intended to mirror Hash#slice it will harmlessly ignore keys
  # not present in the struct.  They will be unset (hsh.include? is not true)
  # as opposed to nil.
  #
  def slice *keys
    keys.inject({}) do |hsh, key|
      hsh[key] = send(key) if respond_to?(key)
      hsh
    end
  end

  #
  # values_at like a hash
  #
  # Since this is intended to mirror Hash#values_at it will harmlessly ignore
  # keys not present in the struct
  #
  def values_of *keys
    keys.map{|key| self.send(key) if respond_to?(key) }
  end

  #
  # Convert to a hash
  #
  def to_hash
    slice(*self.class.members)
  end

  #
  # Analagous to Hash#each_pair
  #
  def pairs
    self.class.members.map{|attr| [attr, self[attr]] }
  end

  #
  # Analagous to Hash#each_pair
  #
  def each_pair *args, &block
    pairs.each(*args, &block)
  end

  #
  # Analagous to Hash#merge
  #
  def merge *args
    self.dup.merge! *args
  end
  def merge! hsh, &block
    raise "can't handle block arg yet" if block
    hsh.each_pair{|key, val| self.send("#{key}=", val) if self.respond_to?("#{key}=") }
    self
  end
  alias_method :update, :merge!

  #
  # Merge hashes recursively.
  # Nothing special happens to array values
  #
  #     x = { :subhash => { 1 => :val_from_x, 222 => :only_in_x, 333 => :only_in_x }, :scalar => :scalar_from_x}
  #     y = { :subhash => { 1 => :val_from_y, 999 => :only_in_y },                    :scalar => :scalar_from_y }
  #     x.deep_merge y
  #     => {:subhash=>{1=>:val_from_y, 222=>:only_in_x, 333=>:only_in_x, 999=>:only_in_y}, :scalar=>:scalar_from_y}
  #     y.deep_merge x
  #     => {:subhash=>{1=>:val_from_x, 222=>:only_in_x, 333=>:only_in_x, 999=>:only_in_y}, :scalar=>:scalar_from_x}
  #
  def deep_merge hsh2
    merge hsh2, &Hash::DEEP_MERGER
  end

  module ClassMethods
    #
    # Instantiate an instance of the struct from a hash
    #
    # Specify has_symbol_keys if the supplied hash's keys are symbolic;
    # otherwise they must be uniformly strings
    #
    def from_hash(hsh, has_symbol_keys=false)
      keys = self.keys
      keys = keys.map(&:to_sym) if has_symbol_keys
      self.new *hsh.values_of(*keys)
    end
    #
    # The last portion of the class in underscored form
    # note memoization
    #
    def self.resource_name
      @resource_name ||= self.to_s.gsub(%r{.*::}, '').underscore.to_sym
    end
  end

  def self.included base
    base.class_eval do
      extend ClassMethods
    end
  end
end
