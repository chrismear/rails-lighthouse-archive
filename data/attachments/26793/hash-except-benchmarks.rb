require 'benchmark'
require 'set'

class Hash
  def except_reject(*keys)
    rejected = Set.new(respond_to?(:convert_key) ? keys.map { |key| convert_key(key) } : keys)
    reject { |k,v| rejected.include?(k) }
  end

  def except_reject!(*keys)
    replace(except_reject(*keys))
  end

  def except_each(*keys)
    clone.except_each!(*keys)
  end

  def except_each!(*keys)
    keys.map! { |key| convert_key(key) } if respond_to?(:convert_key)
    keys.each { |key| delete(key)}
    self
  end
end

# small hash, except
small = { :foo => "bar", :bar => "baz", :this => "that" }
n = 100_000
puts "except, small hash, 100 000 times"
Benchmark.bm(15) do |x|
  x.report("except_reject") do
    n.times { small.except_reject(:bar) }
  end

  x.report("except_each") do
    n.times { small.except_each(:bar) }
  end
end

# small hash, except!
small = { :foo => "bar", :bar => "baz", :this => "that" }
small2 = small.dup
n = 100_000
puts "\nexcept, small hash, 100 000 times"
Benchmark.bm(15) do |x|
  x.report("except_reject!") do
    n.times { small.except_reject!(:bar) }
  end

  x.report("except_each!") do
    n.times { small2.except_each!(:bar) }
  end
end

# big hash, except
big = {}
5000.times do
  big[rand(1_000_000)] = rand
end
n = 1000
puts "\nexcept, big hash, 1000 times"
keys = big.keys[1..1000]
Benchmark.bm(15) do |x|
  x.report("except_reject") do
    n.times { big.except_reject(keys) }
  end

  x.report("except_each") do
    n.times { big.except_each(keys) }
  end
end

# big hash, except!
big = {}
5000.times do
  big[rand(1_000_000)] = rand
end
big2 = big.dup
n = 1000
puts "\nexcept!, big hash, 1000 times"
keys = big.keys[1..1000]
Benchmark.bm(15) do |x|
  x.report("except_reject!") do
    n.times { big.except_reject!(keys) }
  end

  x.report("except_each!") do
    n.times { big2.except_each!(keys) }
  end
end
