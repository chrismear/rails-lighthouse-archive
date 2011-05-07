# Demonstration of a bug in ActiveRecord::Relation: observing a
# relation causes it to change state, i.e. the Heisenberg principal.
#
# Tested in Ruby 1.9.2, Rails 3.0.0
#
# rdp (rdpoor@gmail.com)
# 2010-12-16_05:06:13

=begin
OVERVIEW
========

RefThing table has two fks: obj1_id and obj2_id.  The following lines
correctly create a RefThing and returns 1:

  def works(obj1, obj2)
    relation1 = RefThing.where(:obj1_id => obj1.id)
    relation1.where(:obj2_id => obj2.id).create
    relation1.size
  end

This version returns zero instead, even though it correctly creates a
RefThing.  Note the ONLY difference is the call to relation1.all
before the create:

  def broken(obj1, obj2)
    relation1 = RefThing.where(:obj1_id => obj1.id)
    relation1.all
    relation1.where(:obj2_id => obj2.id).create
    relation1.size
  end

TO REPLICATE
============

irb> load 'ar_heisenberg.rb'
irb> ARHeisenberg.working_test()

Observe: relation1.size correctly equals 1

irb> ARHeisenberg.broken_test()

Observe: relation1.size incorrectly equals 0

=end

class ObjThing < ActiveRecord::Base
end

class RefThing < ActiveRecord::Base
end

class ARHeisenberg
  def self.working_test
    test_common(false)
  end

  def self.broken_test
    test_common(true)
  end

  def self.test_common(force_eval)
    up()
    obj1 = ObjThing.create
    obj2 = ObjThing.create

    relation1 = RefThing.where(:obj1_id => obj1.id)

    # The next line is key: if force is true, it forces an evaluation
    # of relation1.  Although the subsequent create() works properly,
    # the next call to relation1.size returns zero.  If force is
    # false, the call to relation1.size correctly returns 1.
    relation1.all if force_eval

    relation1.where(:obj2_id => obj2.id).create
    if (relation1.size == 1)
      $stderr.puts("success: relation1 has one element")
    else
      $stderr.puts("error: expected relation1 to have one element, but found #{relation1.size} instead")
    end
    $stderr.puts("RefThing is now: #{RefThing.all}")
    down()
  end

  def self.up()
    ActiveRecord::Schema.define do
      create_table "obj_things", :force => true do |t|
      end
      create_table "ref_things", :force => true do |t|
        t.integer "obj1_id"
        t.integer "obj2_id"
      end
    end
  end

  def self.down()
    ActiveRecord::Schema.define do
      drop_table "ref_things"
      drop_table "obj_things"
    end
  end

end
