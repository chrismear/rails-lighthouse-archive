#!/usr/bin/env ruby

require 'activerecord'

ActiveRecord::Base.establish_connection(
 :adapter => "sqlite3",
 :database  => "/tmp/foo.db"
)

conn = ActiveRecord::Base.connection
conn.create_table :courses, :force => true do |t|
  t.string :name
end

conn.create_table :instructors, :force => true do |t|
  t.string :name
end

conn.create_table :courses_instructors, :force => true do |t|
  t.references :course
  t.references :instructor
end

class Course < ActiveRecord::Base
  has_and_belongs_to_many :instructors
end

class Instructor < ActiveRecord::Base
  has_and_belongs_to_many :courses
end

class CoursesInstructor < ActiveRecord::Base
  belongs_to :course
  belongs_to :instructor
end

ruby_course = Course.create! do |course|
  course.name = "Ruby on Rails"
end

john_norman = Instructor.create! do |instructor|
  instructor.name = "John Norman"
  instructor.courses << ruby_course
end

puts ruby_course.to_xml(:include => :instructors)   # this breaks
