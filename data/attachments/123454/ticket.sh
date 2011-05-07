rm -rf xhr_put_id

if [ "$1" = "git" ]; then
  ruby /home/rubys/git/rails/railties/bin/rails xhr_put_id
  cd xhr_put_id
  ln -s /home/rubys/git/rails vendor/rails
else
  rails xhr_put_id
  cd xhr_put_id
fi

ruby script/generate controller users update
cat <<-EOF >test/integration/users_test.rb
require 'test_helper'
class UsersTest < ActionController::IntegrationTest
  test "xhr" do
    xml_http_request :put, "/users/update", :id => 17
    assert_response :success
  end
end
EOF

sed -e "s/def update/def update; redirect_to 'index' unless params['id']/" -i app/controllers/users_controller.rb

rake db:migrate
rake test
