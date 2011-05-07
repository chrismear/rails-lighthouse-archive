rm -rf depot
rails depot
cd depot
ruby script/generate controller store index
cat >app/models/cart.rb <<EOF
class Cart
  attr_reader :items

  def initialize
    items = []
  end
end
EOF

cat >app/controllers/store_controller.rb <<EOF
class StoreController < ApplicationController
  def index
    session[:cart] = Cart.new
  end
end
EOF

ruby script/server

# now, visit http://localhost:3000/store
