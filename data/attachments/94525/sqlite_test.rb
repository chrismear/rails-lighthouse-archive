require 'rubygems'
require 'sqlite3'

# The table name
table = "developers"

# The query in question
query = <<-SQL
  SELECT SUM(salary) as salary 
  FROM "#{table}"  
  GROUP BY salary 
  HAVING SUM(salary) > 10000;
SQL

# The database file
db_file = File.dirname(__FILE__) + "/sqlite_test.db"

# Create the database file if it doesn't exist
File.open(db_file, "w") {|f| f.write "" } unless File.exist?(db_file)

# Get a reference to the database
db = SQLite3::Database.new( db_file )

# Drop table if it exist
db.execute <<-SQL
  DROP TABLE IF EXISTS #{table}; 
SQL

# Create Table
db.execute <<-SQL
  CREATE TABLE #{table} (
   idx INTEGER PRIMARY KEY,
   name VARCHAR(255),
   salary INTEGER
  );
SQL

# Insert some data
[ [1, "Matthias", 100000],
  [2, "Horst",    10050],
  [3, "Inge",     1090]].each do |(id, name, salary)|
    rows = db.execute <<-SQL
      INSERT INTO #{table}
      VALUES (#{id}, '#{name}',#{salary}) 
    SQL
end


# The query in question
db.execute query

rows = db.execute( "select * from #{table}" )

p rows

# Close the connection
db.close