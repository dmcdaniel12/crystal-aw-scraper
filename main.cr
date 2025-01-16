require "http/server"
require "sqlite3"
require "db"
require "json"

def fetch_products
  db = DB.open("sqlite3://./products.db")
  results = [] of Hash(String, String)

  db.query("SELECT data_asin, price FROM products") do |rs|
    rs.each do
      puts rs.to_s
      # results << rs
    end
  end
  puts results
  results
end

# Generate HTML with a bar graph
def generate_html(products)
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
      const data = #{products.to_json};
      const labels = data.map(item => item["data_asin"]);
      const prices = data.map(item => parseFloat(item["price"].replace("$", "").replace(",", "")));

      const ctx = document.getElementById('productChart').getContext('2d');
      new Chart(ctx, {
        type: 'bar',
        data: {
          labels: labels,
          datasets: [{
            label: 'Prices',
            data: prices,
            backgroundColor: 'rgba(75, 192, 192, 0.2)',
            borderColor: 'rgba(75, 192, 192, 1)',
            borderWidth: 1
          }]
        },
        options: {
          scales: {
            y: {
              beginAtZero: true
            }
          }
        }
      });
    </script>
  </body>
  </html>
  HTML
end

# HTTP server setup
server = HTTP::Server.new do |context|
  products = fetch_products
  context.response.content_type = "text/html"
  context.response.print generate_html(products)
end

address = server.bind_tcp "127.0.0.1", 8080
puts "Listening on http://#{address}"
server.listen
