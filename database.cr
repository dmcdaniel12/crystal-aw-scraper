require "sqlite3"
require "db"

class Database
  @db : DB::Database

  def initialize
    @db = DB.open("sqlite3://./products.db")
    create_products_table_if_not_exists
  end

  def create_products_table_if_not_exists
    query = <<-SQL
      CREATE TABLE IF NOT EXISTS products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        data_asin TEXT NOT NULL,
        product_name TEXT NOT NULL,
        price TEXT NOT NULL
      )
    SQL
    @db.exec(query)
    puts "Ensured products table exists."
  end

  def insert_product(data_asin : String, product_name : String, price : String)
    query = "INSERT INTO products (data_asin, product_name, price) VALUES (?, ?, ?)"
    @db.exec(query, data_asin, product_name, price)
    puts "Inserted product: #{product_name} with ID: #{data_asin} and Price: #{price}"
  end
end
