require 'rubygems'
require 'active_record'

class Test < ActiveRecord::Base
end

Test.establish_connection :adapter => "postgresql", 
                          :database => "test"

Test.find_by_sql(["select ? as a", "test"])
class PGconn
  alias old_escape escape

  def escape(s)
    val = old_escape(s)
    Thread.current[:escape_logger] << [:escape, val, s]
    val
  end
end
class ActiveRecord::ConnectionAdapters::PostgreSQLAdapter
  alias old_quote_string quote_string

  def quote_string(s)
    val = old_quote_string(s)
    Thread.current[:escape_logger] << [:quote_string, val, s]
    val
  end
end

def test
  Thread.current[:escape_logger] = []
  a, b, c, d = "test", 42, "another test", 13
  t = Test.find_by_sql(["select ? as a, ? as b, ? as c, ? as d", a, b, c, d])[0]
  if t.a == a && t.b == b && t.c == c && t.d == d
    # puts "OK"
  else 
    p t
    p Thread.current[:escape_logger]
    puts "fail"
  end
end

30.times do
  Thread.fork { loop { test } }
end
sleep 1000
