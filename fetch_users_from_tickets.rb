#!/usr/bin/env ruby

require 'rubygems'
require 'nokogiri'

USER_ID_XPATHS = [
  '//ticket/assigned-user-id',
  '//ticket/creator-id',
  '//ticket/user-id',
  '//ticket/versions/version/assigned-user-id',
  '//ticket/versions/version/creator-id',
  '//ticket/versions/version/user-id'
]

Dir.chdir "data/users"

ticket_ids = Dir.glob("../tickets/*.xml").map{|p| p.match(/\d+/)[0].to_i}.sort

ticket_ids.each do |ticket_id|
  ticket_doc = nil
  puts "Parsing ticket #{ticket_id}:"
  File.open("../tickets/#{ticket_id}.xml") do |ticket_file|
    ticket_doc = Nokogiri::XML(ticket_file)
  end

  user_ids_to_fetch = []
  USER_ID_XPATHS.each do |user_id_xpath|
    user_ids = ticket_doc.xpath(user_id_xpath).map{|node| node.content.to_i}
    user_ids_to_fetch += user_ids
  end

  user_ids_to_fetch.uniq!.reject!{|id| id < 1}

  puts "Found user ids: #{user_ids_to_fetch.join(", ")}"

  user_ids_to_fetch.each do |user_id|
    unless File.exist?("#{user_id}.xml")
      cmd = "wget http://rails.lighthouseapp.com/users/#{user_id}.xml"
      `#{cmd}`
    end
  end
end
