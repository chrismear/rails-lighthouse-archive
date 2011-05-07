# use like this:
# rails appname -m /Volumes/Projekte/rails-templates/bjoern.rb

# install Gems
gem 'RedCloth', :lib => 'redcloth'
gem 'mislav-will_paginate', :lib => 'will_paginate', :source => 'http://gems.github.com'
rake "gems:install"

# install Plugins
#if yes?("Do you want to use RSpec?")
  plugin "rspec", :git => "git://github.com/dchelimsky/rspec.git"
  plugin "rspec-rails", :git => "git://github.com/dchelimsky/rspec-rails.git"
  generate :rspec
#end
plugin 'role_requirement',
  :git => 'git://github.com/timcharper/role_requirement.git'
plugin 'restful-authentication',
  :git => 'git://github.com/technoweenie/restful-authentication.git'
plugin 'exception_notifier',
  :git => 'git://github.com/rails/exception_notification.git'

# Set up git
git :init

file ".gitignore", <<-END
.DS_Store
log/*.log
tmp/**/*
config/database.yml
db/*.sqlite3
END
 
run "touch tmp/.gitignore log/.gitignore vendor/.gitignore"
run "cp config/database.yml config/example_database.yml"
git :add => ".", :commit => "-m 'initial commit'"

# Authentication
generate("authenticated", "--rspec --include-activation user session")
generate("rspec")
rake "db:migrate"
git :add => ".", :commit => "-m 'adding authentication'"

#Roles
run "mv app/controllers/application_controller.rb app/controllers/application.rb"
generate("roles", "Role User")
run "mv app/controllers/application.rb app/controllers/application_controller.rb"

rake "db:migrate"

git :add => ".", :commit => "-m 'adding roles'"

# Get rid of some files
git :rm => "public/index.html"

#generate plugin
generate :plugin, "welcome"

file "vendor/plugins/welcome/app/controllers/welcome_controller.rb", <<-END
class WelcomeController < ApplicationController
  def index
    @content ="This message will only be displayed once. Please reload or move the welcome controller to the regular app/controller"
  end
end
END

file "vendor/plugins/welcome/app/views/welcome/index.html.erb", <<-END
<%= @content %>

<!-- the next line causes problems here but does not, if the welcome controller and the 
     view are moved out of the plugin into the rails app -->
<% if !current_user.nil? && current_user.has_role?('admin') %>
You are admin
<% end %>
END

route "map.root :controller => 'welcome'"
