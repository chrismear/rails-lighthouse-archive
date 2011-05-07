require 'rubygems'
require 'gorp/test'

class LazyLookupTest < Gorp::TestCase
  test "I18N lazy lookup" do
    rails 'testapp'
    ruby 'script/generate scaffold product title:string'
    rake 'db:migrate'

    edit 'config/locales/en.yml' do |locales|
      locales.msub /(^\s+hello:.*)/, ''
      locales << <<-EOF.unindent(6)
        products:
          index:
            hello: "Hello world!"
      EOF
    end

    edit 'app/views/products/index.html.erb' do |index|
      index << "\n" + <<-EOF.unindent(8)
        <p class="hello"><%= t('.hello') %></p>
      EOF
    end

    ruby 'script/server'

    get '/products' do
      assert_select '.hello', 'Hello world!'
    end
  end
end
