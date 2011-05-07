require 'rubygems'
require 'test/unit'
require 'active_support/test_case'
require 'active_resource'
require 'active_resource/http_mock'


class Destinatario < ActiveResource::Base
  self.site = "http://apogeo.heroku.com/accounts/:account_id/campaigns/:campaign_id/"
end

DEST = '<?xml version="1.0" encoding="UTF-8"?>
<destinatarios type="array">
  <destinatario>
    <campaign-id type="integer">4</campaign-id>
    <created-at type="datetime">2010-04-27T19:41:19Z</created-at>
    <id type="integer">1</id>
    <name>Juan</name>
    <phone>2222</phone>
    <state nil="true"></state>
    <time-to-call type="datetime" nil="true"></time-to-call>
    <updated-at type="datetime">2010-04-27T19:41:19Z</updated-at>
  </destinatario>
</destinatarios>'

DEST_SAVE = '<?xml version="1.0" encoding="UTF-8"?>
<destinatario>
  <name>Juan</name>
  <created-at type="datetime">2010-04-27T19:41:19Z</created-at>
  <updated-at type="datetime">2010-04-27T19:41:19Z</updated-at>
  <id type="integer">1</id>
  <phone>2222</phone>
  <time-to-call nil="true"></time-to-call>
  <state nil="true"></state>
</destinatario>
'


class PrefixOptionBugTest < Test::Unit::TestCase
  def setup
    @params = { :account_id => 1, :campaign_id => 4 }
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/accounts/1/campaigns/4/destinatarios/available.xml", {'Accept' => 'application/xml'}, DEST
      mock.get "/accounts/1/campaigns/4/destinatarios.xml", {'Accept' => 'application/xml'}, DEST
      mock.put "/accounts/1/campaigns/4/destinatarios/1.xml", {'Content-Type' => 'application/xml'}, DEST_SAVE
    end
  end

  def test_prefix_option_filled_on_returned_items_from_normal_find
    dest = Destinatario.find( :all, :params =>  @params).first
    assert dest.save
  end

  def test_prefix_option_filled_after_returned_item_is_saved
    dest = Destinatario.find( :all, :params =>  @params).first
    assert dest.save
    assert dest.save
    assert_equal @params, dest.prefix_options
  end

  def test_prefix_option_filled_on_returned_items_from_find_with_from_option
    dest = Destinatario.find( :all, :from => :available, :params => @params).first
    assert dest.save
  end

  def test_prefix_option_filled_on_returned_items_from_find_with_from_option_work_around
    dest = Destinatario.find( :all, :from => :available, :params => @params).first
    dest.prefix_options = @params
    assert dest.save
  end

  def test_prefix_option_filled_on_returned_items_after_item_is_saved
    dest = Destinatario.find( :all, :from => :available, :params => @params).first
    dest.prefix_options = @params
    dest.save
    dest.save
    assert_equal @params, dest.prefix_options
  end

end
