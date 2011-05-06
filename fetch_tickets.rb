1.upto(6770) do |id|
  cmd = "wget https://rails.lighthouseapp.com/projects/8994/tickets/#{id}.xml"
  `#{cmd}`
  sleep 0.5
end
