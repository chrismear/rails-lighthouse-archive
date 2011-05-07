cd /tmp
rails foo
cd foo
ruby script/generate model membership name:string
ruby script/generate model property_detail short:string
ruby script/generate model join_property_detail membership_id:integer property_detail_id:integer

echo "class Membership < ActiveRecord::Base
  has_many :join_property_details
  has_many :property_details, :through => :join_property_details
end" > app/models/membership.rb

echo "class JoinPropertyDetail < ActiveRecord::Base
  belongs_to :membership
  belongs_to :property_detail
  validates_uniqueness_of :property_detail_id, :scope => :membership_id
end" > app/models/join_property_detail.rb

echo "class Country < ActiveRecord::Base
  has_many :join_property_details
  has_many :memberships, :through => :join_property_details
end" > app/models/country.rb

#sudo gem install sqlite3-ruby

rake db:migrate

ruby script/console

  apl = PropertyDetail.create(:short => "APL")
  cs = PropertyDetail.create(:short => "CS")
  np = PropertyDetail.create(:short => "NP")
  z = PropertyDetail.create(:short => "Z")
  pl = PropertyDetail.create(:short => "PL")

  # members with a properties in specific countries
  member_john  = Membership.create(:name => "John")
  member_james = Membership.create(:name => "James")
  member_nancy = Membership.create(:name => "Nancy")

  # members want to visit many countries
  JoinPropertyDetail.create(:membership => member_john, :property_detail => apl)
  JoinPropertyDetail.create(:membership => member_john, :property_detail => np)
  JoinPropertyDetail.create(:membership => member_john, :property_detail => pl)
  JoinPropertyDetail.create(:membership => member_john, :property_detail => z)

  JoinPropertyDetail.create(:membership => member_james, :property_detail => cs)
  JoinPropertyDetail.create(:membership => member_james, :property_detail => np)
  JoinPropertyDetail.create(:membership => member_james, :property_detail => z)

  JoinPropertyDetail.create(:membership => member_nancy, :property_detail => apl)
  JoinPropertyDetail.create(:membership => member_nancy, :property_detail => cs)
  JoinPropertyDetail.create(:membership => member_nancy, :property_detail => z)


  # show Nancys property_details
  p member_nancy.property_details.map(&:short)

  # create a anonymous named scope
  scope = Membership.scoped({})

  # I search members with properties in CH and US
  search_for = ['APL', 'Z']
  scope = scope.scoped(
   :include => [:property_details],
   :conditions => ['property_details.short IN (?)',  search_for],
   :group => "memberships.id HAVING COUNT(memberships.id) = #{search_for.size}" )

  # execute scope
  scope

  # doesn't include group by and returns 3
  scope.count

  # is correct of course and shows 2
  scope.size
