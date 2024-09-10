# BOJ Exchange Rates Scraper

A simple shell script to fetch the exchange rates from the Bank of Jamaica (BOJ) website. The script retrieves a security token required for accessing the rates data and saves the output to a JSON file.

## Features

- Automatically fetches the required security token from the BOJ website.
- Sends a POST request to retrieve the latest exchange rates.
- Saves the output to a specified file location.
- Handles errors and retries if the initial token is invalid.

## Requirements

- `curl`: Required for HTTP requests. Ensure `curl` is installed and accessible in your system's PATH.
- `grep` and `sed`: Used for extracting tokens from the webpage. These tools are typically pre-installed on most Unix-based systems like Linux and macOS.

## Usage

1. **Clone the repository:**

   ```bash
   git clone https://github.com/yourusername/boj-exchange-rates-scraper.git
   cd boj-exchange-rates-scraper
   bash fetch_boj_rates.sh

## Disclaimer

This script is provided for educational and personal use only. The author does not guarantee the legality of using this script to scrape data from the Bank of Jamaica's website or any other website. Users are responsible for ensuring that their use of this script complies with the terms of service of the website being scraped. The author assumes no liability for any misuse of this script.
