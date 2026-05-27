require_relative "../config/environment"
require "pp"

crawler = VietnamworksCrawler.new(strategy: "html")
jobs = crawler.crawl(pages: 5)

pp jobs
