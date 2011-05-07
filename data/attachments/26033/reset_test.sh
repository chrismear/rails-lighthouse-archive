#!/bin/sh
# usage: env RUBY_COMMAND=ruby18 RAILS_VERSION=2.0.2 ./reset_test.sh
: ${RUBY_COMMAND:=ruby}
set -ex
rails ${RAILS_VERSION+_${RAILS_VERSION}_} reset_test
cd reset_test
$RUBY_COMMAND ./script/generate model item
rake db:migrate
$RUBY_COMMAND -pli~ -e 'sub!(/cache_classes = true/){"cache_classes = false"}' config/environments/test.rb
cat <<EOF >test/unit/item_test.rb
require 'test_helper'

class ItemTest < ActiveSupport::TestCase
  def test_reset_subclasses
    assert_equal :load, Dependencies.mechanism
    assert Dependencies.autoloaded?(Item)
    item = Item.create
    assert_equal 1, item.id
    ActiveRecord::Base.reset_subclasses
    item = Item.find(1)
    assert_equal 1, item.id
  end
end
EOF
rake
