require 'rubygems'
require 'test/unit'
require 'action_controller'

class Utf8Select < Test::Unit::TestCase
  include ActionDispatch::Assertions::SelectorAssertions

  def test_select_ascii
    text = 'Mr Frog'
    @selected = HTML::Document.new("<p>#{text}</p>").root.children
    assert_select 'p', /Frog/
  end

  def test_select_utf8
    text = [83, 101, 241, 111, 114, 32, 70, 114, 111, 103].pack('U*')
    text = text.force_encoding('utf-8') if text.respond_to?(:force_encoding)
    @selected = HTML::Document.new("<p>#{text}</p>").root.children
    assert_select 'p', /Frog/
  end
end
