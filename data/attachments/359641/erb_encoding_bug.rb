# encoding: ascii-8bit
require 'erb'

def results(name, result)
  puts "#{name}: #{result}"
end

results "__ENCODING__", __ENCODING__


puts "\n\n*** Testing a simple ASCII character"
results "Basic Encoding:",    'a'.encoding
results "ERB src:",           ERB.new('a').src.encoding
results "Eval'd src:",        eval(ERB.new('a').src).encoding
results "ERB embed",          ERB.new("<%= 'a' %>").src.encoding
results "ERB embed eval",     eval(ERB.new("<%= 'a' %>").src).encoding

results "Magic src",          ERB.new('<%# encoding: utf-8 %>a').src.encoding
results "Magic src eval",     eval(ERB.new('<%# encoding: utf-8 %>a').src).encoding
results "Magic embed",        ERB.new("<%# encoding: utf-8 %><%= 'a' %>").src.encoding
results "Magic embed eval",   eval(ERB.new("<%# encoding: utf-8 %><%= 'a' %>").src).encoding

puts "\n\n*** Testing a UTF-8 character"
results "Basic Encoding:",    '日'.encoding
results "ERB src:",           ERB.new('日').src.encoding
results "Eval'd src:",        eval(ERB.new('日').src).encoding
results "ERB embed",          ERB.new("<%= '日' %>").src.encoding
results "ERB embed eval",     eval(ERB.new("<%= '日' %>").src).encoding

results "Magic src",          ERB.new('<%# encoding: utf-8 %>日').src.encoding
results "Magic src eval",     eval(ERB.new('<%# encoding: utf-8 %>日').src).encoding
results "Magic embed",        ERB.new("<%# encoding: utf-8 %><%= '日' %>").src.encoding
results "Magic embed eval",   eval(ERB.new("<%# encoding: utf-8 %><%= '日' %>").src).encoding
