b1r = 0xc0..0xc2
b2r = 0x80..0xbf

b1r.each do |b1|
  b2r.each do |b2|
    string = [b1,b2].pack("C*")
    begin
      string.unpack("U*")
      puts "WORKED: \"\\x%02x\\x%02x\"" % [b1,b2]
      exit
    rescue ArgumentError => e
      if e.message =~ /redundant/i
        puts "FAILED: \"\\x%02x\\x%02x\"" % [b1,b2]
      else
        raise
      end
    end
  end
end
