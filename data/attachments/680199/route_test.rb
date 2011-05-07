require 'test_helper'

class RouteTest < ActiveSupport::TestCase

  def setup
    @rs_defaults_via = ActionDispatch::Routing::RouteSet.new
    @rs_defaults_via.draw do
      match '/error' => "bug#index", :defaults => {:format => "jpg"}, :via => :get
    end

  	@rs_defaults = ActionDispatch::Routing::RouteSet.new
    @rs_defaults.draw do
      match '/error' => "bug#index", :defaults => {:format => "jpg"}
    end

  	@rs_via = ActionDispatch::Routing::RouteSet.new
    @rs_via.draw do
      match '/error' => "bug#index", :via => :get
    end

    @rs_prepend = ActionDispatch::Routing::RouteSet.new
    @rs_prepend.draw do
      match '/' => 'root#index'
      get '/error' => "bug#index", :defaults => {:format => "jpg"}
    end
  end

  # FIXME this test fails
  def test_defaults_via
    assert_nothing_raised(ActionController::RoutingError) do
      @rs_defaults_via.generate :controller => :bug
    end
  end

  def test_prepend
    assert_nothing_raised(ActionController::RoutingError) do
      @rs_prepend.generate :controller => :bug
    end
  end

  def test_via
  	assert_nothing_raised(ActionController::RoutingError) do
      @rs_via.generate :controller => :bug
    end
  end

  def test_defaults
  	assert_nothing_raised(ActionController::RoutingError) do
      @rs_defaults.generate :controller => :bug
    end
  end

end
