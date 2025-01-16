# Project Overview

Web application written in Crystal that displays product prices in a line graph. It includes a scraper to populate product data into a sqlite database and a simple HTTP server that serves a page with the chart.

## Overview of Decisions and Resources Used to Learn Crystal

### Resources Used:
- Crystal Programming Language Documentation: [https://crystal-lang.org/docs/](https://crystal-lang.org/docs/)
- SQLite3 Documentation: [https://www.sqlite.org/docs.html](https://www.sqlite.org/docs.html)
- Chart.js Documentation: [https://www.chartjs.org/docs/latest/](https://www.chartjs.org/docs/latest/)

## Architecture Decisions

### Web Scraper:
- Designed as a standalone class (`Scraper`) to keep the scraping logic modular and reusable.
- It inserts scraped data directly into the SQLite3 database via the `Database` class.

### HTTP Server:
- Built using Crystal's built-in `HTTP::Server` module.
- Routes:
  - `/`: Serves the main HTML page displaying the chart.
  - `/rescrape`: Triggers the scraper and responds with a JSON success or error message.

### Auto-Refresh:
- The "Re-Scrape" button triggers a server call to the `/rescrape` route. Upon completion, the page refreshes automatically to display updated data.

## Database Table Design
- **Table Name**: `products`
- **Columns**:
  - `id`: Integer (Primary Key, Auto Increment)
  - `data_asin`: Text (Unique identifier for products)
  - `product_name`: Text (Name of the product)
  - `price`: Text (Price of the product in string format, parsed into float for charting)

## High-Level Overview of Files

### `main.cr`
- Handles HTTP server setup and routing.
- Generates dynamic HTML for the line graph.
- Includes the "Re-Scrape" functionality.

### `database.cr`
- Encapsulates database operations.
- Ensures the `products` table exists.
- Provides methods for inserting product data.
- Some more updates are needed here to encapsulate the calls in main.cr but I didn't get to that yet

### `scraper.cr`
- Contains the scraping logic.
- Parses data and inserts it into the database.

## List of Resources Used to Learn Crystal
1. Crystal Official Documentation: [https://crystal-lang.org/docs/](https://crystal-lang.org/docs/)
2. SQLite3 Documentation: [https://www.sqlite.org/docs.html](https://www.sqlite.org/docs.html)
3. Chart.js Documentation: [https://www.chartjs.org/docs/latest/](https://www.chartjs.org/docs/latest/)
4. Tutorials and Guides:
   - [Crystal for Rubyists](https://crystal-lang.org/reference/guides/welcome/)
   - Various blog posts and Stack Overflow discussions.
