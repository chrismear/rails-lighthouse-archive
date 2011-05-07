#!/usr/bin/env ruby

require 'rubygems'
require 'nokogiri'

Dir.chdir "data/attachments"

ticket_ids = Dir.glob("../tickets/*.xml").map{|p| p.match(/\d+/)[0].to_i}.sort
ticket_ids.each do |ticket_id|
  puts "Parsing ticket #{ticket_id}:"
  ticket_doc = nil
  File.open("../tickets/#{ticket_id}.xml") do |ticket_file|
    ticket_doc = Nokogiri::XML(ticket_file)
  end
  attachments_to_fetch = {}
  attachment_nodes = ticket_doc.xpath('//ticket/attachments/attachment')
  attachment_nodes.each do |attachment_node|
    id = attachment_node.at_xpath('id').content.to_i
    url = attachment_node.at_xpath('url').content
    filename = attachment_node.at_xpath('filename').content
    attachments_to_fetch[id] = {:url => url, :filename => filename}
  end
  puts "Found attachments: #{attachments_to_fetch.keys.join(", ")}"
  attachments_to_fetch.each_pair do |id, data|
    unless File.exist?(id.to_s)
      Dir.mkdir(id.to_s)
      Dir.chdir(id.to_s)
      `curl -L -o "#{data[:filename]}" "#{data[:url]}"`
      Dir.chdir('..')
    end
  end
end
