require 'benchmark'
require 'set'

class Hash
  def slice_current(*keys)
    allowed = Set.new(respond_to?(:convert_key) ? keys.map { |key| convert_key(key) } : keys)
    reject { |key,| !allowed.include?(key) }
  end

  def slice_patched(*keys)
    allowed = Set.new(respond_to?(:convert_key) ? keys.map { |key| convert_key(key) } : keys)
    hash = {}
    allowed.each { |k| hash[k] = self[k] }
    hash
  end
end

small = { :foo => "bar", :bar => "baz", :this => "that" }
n = 10_0000
Benchmark.bm(15) do |x|
  x.report("small hash#slice_current") do
    n.times { small.slice_current(:this) }
  end

  x.report("small hash#slice_patched") do
    n.times { small.slice_patched(:this) }
  end
end

big = {}
5000.times do
  big[rand(1_000_000)] = rand
end
n = 100
keys = big.keys[1..1000]
Benchmark.bm(15) do |x|
  x.report("big hash#slice_current") do
    n.times { big.slice_current(keys) }
  end

  x.report("big hash#slice_patched") do
    n.times { big.slice_patched(keys) }
  end
end