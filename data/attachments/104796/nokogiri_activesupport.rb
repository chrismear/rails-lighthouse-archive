require 'rubygems'
require 'activesupport'
require 'nokogiri'
require 'rexml/document'
include ActiveSupport
xml = "<url>http://someurl.somethingelse.com/whoami/heyyou/game/game.jsp?Suite=flash&usefulldata=2342fdsfsd&account=HeyMan&Nokogiri=superparser&somethingelse=0&thereismore=38&onemore=EN</url>"
p Hash.from_xml(xml)
XmlMini.backend = 'Nokogiri'
p Hash.from_xml(xml)
  

