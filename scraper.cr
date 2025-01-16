require "http"
require "xml"
require "./database"

class Scraper
    def initialize
      @url = "https://bush-daisy-tellurium.glitch.me/"
      @db = Database.new
    end
  
    def url
      @url
    end
  
    # Scrape the page and extract product information
    def scrape_page
      puts "Scraping page #{@url}"

      headers = HTTP::Headers.new
      headers["Referer"] = url
      body = HTTP::Client.get(url, headers: headers).body

      parsed = XML.parse_html(body) 

      # Get all the product cards on the page and loop them, grabbing information out
      parsed.xpath_nodes("//div[contains(@class, 'product-card')]").each do |product_card|
        product_card.xpath_nodes(".//div[contains(@class, 'content')]").each do |content|
          
          # Gets product ID or throws error
          product_id = content["data-asin"]? || raise "Error: Missing product id attribute"
      
          # Gets product name or throws error
          product_name_node = content.xpath_nodes(".//h3").first || raise "Error: Missing product name"
          product_name = product_name_node.text.strip
      
          # Gets product price or throws error
          price_node = content.xpath_nodes(".//div[contains(@class, 'price')]").first || raise "Error: Missing product price"
          raw_price = price_node.text.strip

          # Cleanup price and remove $ and , characters
          sanitized_price = raw_price.gsub(/[$,]/, "")
      
          # Insert into the database
          @db.insert_product(product_id, product_name, sanitized_price)
        end
      end
       
    end
  end
