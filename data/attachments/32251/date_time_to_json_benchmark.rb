require 'benchmark'
require 'date'

class DateTime
  def to_json_original
    %("#{strftime("%Y/%m/%d %H:%M:%S %z")}")
  end
  
  def to_json_patched
    strftime('"%Y/%m/%d %H:%M:%S %z"')
  end
end

n = 100_000
dt = DateTime.civil(2008, 7, 1, 0, 0, 0)
Benchmark.bm(8) do |x|
  x.report("original") do
    n.times { dt.to_json_original }
  end
  x.report("patched") do
    n.times { dt.to_json_patched }
  end
end

#               user     system      total        real
# original 62.240000   0.090000  62.330000 ( 62.431844)
# patched  62.090000   0.090000  62.180000 ( 62.276596)
# 
