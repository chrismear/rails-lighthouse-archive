class Test
  def quote_string(s)
    self.class.instance_eval do
      define_method(:quote_string) do |s|
        sleep 0.1
        s
      end
    end
    quote_string(s)
  end
end

$c = 0
def test
  t = Test.new
  a, b = "test", "another test"
  ta, tb = t.quote_string(a), t.quote_string(b)
  if ta == a && tb == b
    # puts "OK"
    $c += 1
  else
    puts "#{$c += 1} fail #{[ta, tb].inspect}"
  end
end

30.times do
  Thread.fork { loop { test } }
end
sleep 1