require 'active_record'

#install the following gems:
# ruby-oci8
# activerecord-oracle_enhanced-adapter
# add %TNS_ADMIN% to the path

#shoul have the env variable %TNS_ADMIN% pointed to the  C:\Program Files\Oracle\instantclient
# so that Ruby could find the needed dll files

#in case of getting the message; "Warning: NLS_LANG is not set. fallback to US-ASCII."
# set "NLS_LANG" environment variable to "AMERICAN_AMERICA.UTF8" for example


ActiveRecord::Base.establish_connection(
  :adapter => 'oracle_enhanced',
  :database => 'DEV_PACE06_NLAPAC02',  
  :username => 'wchilldev',
  :password => 'wchilldev'
)

class Supplier < ActiveRecord::Base 
  set_table_name :lcssupplier  
  set_primary_key :ida2a2     
end

dpp_supplier = Supplier.where(:num2=>56180).first
puts "att1 before update: #{dpp_supplier.att1}"
dpp_supplier.update_attribute(:att1, "DP China / Shanghai - SHENZHOU KNITTING(AN HUI)CO.LTD - TESTING")
puts "att1 after update: #{dpp_supplier.att1}"




