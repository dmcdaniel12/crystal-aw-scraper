require "http/server"
require "db"
require "sqlite3"
require "json"
require "./database"
require "./scraper"

def fetch_products : Array(Hash(String, String))
  db = Database.new
  results = [] of Hash(String, String)

  db_query = "SELECT data_asin, price FROM products"
  db.@db.query(db_query) do |rs|
    rs.each do
      results << {"data_asin" => rs.read(String), "price" => rs.read(String)}
    end
  end
  results
end

# Generate HTML with a line graph
def generate_html(products : Array(Hash(String, String))) : String
  grouped_products = products.group_by { |item| item["data_asin"] }
  colors = ["rgba(255, 0, 0, 1)", "rgba(0, 0, 255, 1)", "rgba(0, 255, 0, 1)"]

  datasets = grouped_products.map_with_index do |(asin, items), index|
    prices = items.map { |item| parse_price(item["price"]) }
    {
      label: asin,
      data: prices,
      borderColor: colors[index % colors.size], # Cycle through colors
      fill: false
    }
  end

  <<-HTML
  <!DOCTYPE html>
  <html>
  <head>
    <title>Product Prices</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
  </head>
  <body>
    <h1>Product Prices</h1>
    <canvas id="productChart" width="400" height="200"></canvas>
    <script>
      const datasets = #{datasets.to_json};

      const ctx = document.getElementById('productChart').getContext('2d');
      new Chart(ctx, {
        type: 'line',
        data: {
          labels: Array.from({length: datasets[0].data.length}, (_, i) => i + 1),
          datasets: datasets
        },
        options: {
          scales: {
            x: {
              title: {
                display: true,
                text: 'Scrape Count'
              }
            },
            y: {
              beginAtZero: true,
              title: {
                display: true,
                text: 'Price'
              }
            }
          }
        }
      });

      // Re-scrape button handler
      async function rescrape() {
        try {
          const response = await fetch('/rescrape', { method: 'POST' });
          const result = await response.json();
          if (result.success) {
            window.location.reload(); // Automatically refresh the page
          } else {
            alert('Re-scraping failed. Please try again later.');
          }
        } catch (error) {
          console.error('Error during re-scraping:', error);
          alert('An error occurred while re-scraping.');
        }
      }
    </script>
    <button onclick="rescrape()">Re-Scrape</button>
  </body>
  </html>
  HTML
end

def scrape_products
  scraper = Scraper.new
  scraper.scrape_page
end

# Helper function to parse prices
def parse_price(price : String) : Float64
  price.gsub(/[^\d.]/, "").to_f
end

# HTTP server
server = HTTP::Server.new do |context|
  if context.request.path == "/rescrape"
    begin
      scrape_products()
      context.response.content_type = "application/json"
      context.response.print %({"success": true})
    rescue ex : Exception
      context.response.status_code = 500
      context.response.content_type = "application/json"
      context.response.print %({"success": false, "error": "#{ex.message}"})
    end
  else
    products = fetch_products
    context.response.content_type = "text/html"
    context.response.print generate_html(products)
  end
end

address = server.bind_tcp "127.0.0.1", 8080
puts "Listening on http://#{address}"
server.listen
