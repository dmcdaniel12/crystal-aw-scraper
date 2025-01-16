require "sqlite3"
require "db"

class Database
  @db : DB::Database

  def initialize
    @db = DB.open("sqlite3://./products.db")
  end

  def insert_product(data_asin : String, product_name : String, price : String)
    query = "INSERT INTO products (data_asin, product_name, price) VALUES (?, ?, ?)"
    @db.exec(query, data_asin, product_name, price)
    puts "Inserted product: #{product_name} with ID: #{data_asin} and Price: #{price}"
  end
end
