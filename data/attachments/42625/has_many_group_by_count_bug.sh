cd /tmp
rails foo
cd foo
ruby script/generate model reviewer name:string
ruby script/generate model review reviewer_id:integer book_id:integer notes:string
ruby script/generate model book name:string
echo "class Reviewer < ActiveRecord::Base
  has_many :reviews
  has_many :books, :through => :reviews, :group => \"books.id\"
end" > app/models/reviewer.rb
echo "class Review < ActiveRecord::Base
  belongs_to :book
  belongs_to :reviewer
end" > app/models/review.rb
echo "class Book < ActiveRecord::Base
  has_many :reviews
  has_many :reviewers, :through => :reviews, :group => \"reviews.id\"
end" > app/models/book.rb

#sudo gem install sqlite3-ruby

rake db:migrate

ruby script/console

  Reviewer.destroy_all
  Book.destroy_all
  Review.destroy_all

  alan = Reviewer.create(:name => "alan")
  bob = Reviewer.create(:name => "bob")

  book1 = Book.create(:name => "theory of eveything")
  book2 = Book.create(:name => "war of the worlds")

  #they each review the books
  Review.create(:reviewer => alan, :book => book1, :notes => "meh")
  Review.create(:reviewer => bob, :book => book1, :notes => "it was ok")
  Review.create(:reviewer => alan, :book => book2, :notes => "wel...")
  Review.create(:reviewer => bob, :book => book2, :notes => "hated it")

  #reviews after a second read
  Review.create(:reviewer => alan, :book => book1, :notes => "i liked it better the second time")
  Review.create(:reviewer => bob, :book => book2, :notes => "still bad")
  
  #a third review from the amazing alan
  Review.create(:reviewer => alan, :book => book1, :notes => "i love it")


  alan = Reviewer.find_by_name("alan")
  bob = Reviewer.find_by_name("bob")

  alan.books.size # => 4
    # SELECT count(*) AS count_all FROM "books" INNER JOIN reviews ON books.id = reviews.book_id WHERE (("reviews".reviewer_id = 1)) 
    
  bob.books.size  # => 3
    # SELECT count(*) AS count_all FROM "books" INNER JOIN reviews ON books.id = reviews.book_id WHERE (("reviews".reviewer_id = 2)) 

  alan.books.to_a.size # => 2
    # SELECT "books".* FROM "books" INNER JOIN reviews ON books.id = reviews.book_id WHERE (("reviews".reviewer_id = 1)) GROUP BY books.id
    
  bob.books.to_a.size  # => 2
    # SELECT "books".* FROM "books" INNER JOIN reviews ON books.id = reviews.book_id WHERE (("reviews".reviewer_id = 2)) GROUP BY books.id


#Shouldn't "alan.books.size" generate SQL like this:
#  SELECT count(distinct books.id) AS count_all FROM "books" INNER JOIN reviews ON books.id = reviews.book_id WHERE (("reviews".reviewer_id = 1)) 

