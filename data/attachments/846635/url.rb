#standard rails controller

#Controller
class MyController < ApplicationController

 def index
  @url="Hello world"
 end

end

#View
#@url is empty
<h1><%= @url %></h1>



########################################################

#Metal Controller
class MyController < ActionController::Metal

 def index
  @url="Hello world"
 end

end


#View
#@url is not empty, all ok
<h1><%= @url %></h1>


