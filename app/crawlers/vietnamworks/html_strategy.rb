module Vietnamworks
  class HtmlStrategy < BaseCrawler
    SOURCE   = "vietnamworks"
    BASE_URL = "https://www.vietnamworks.com/viec-lam"

    private

    def fetch_page(page)
      require "selenium-webdriver"

      html = render_page(page)
      doc  = Nokogiri::HTML(html)

      doc.css("[class*='job_list'] [class*='job']").map do |card|
        normalize(card)
      end.compact
    end

    def render_page(page)
      driver = build_driver
      driver.navigate.to("#{BASE_URL}?page=#{page}")
      wait = Selenium::WebDriver::Wait.new(timeout: 15)
      wait.until { driver.find_elements(css: "[class*='job']").any? }
      driver.page_source
    ensure
      driver&.quit
    end

    def build_driver
      options = Selenium::WebDriver::Options.chrome
      options.add_argument("--headless=new")
      options.add_argument("--no-sandbox")
      options.add_argument("--disable-dev-shm-usage")
      Selenium::WebDriver.for(:chrome, options: options)
    end

    def normalize(card)
      link = card.at_css("a")
      return nil if link.nil?

      {
        title:        card.at_css("[class*='title']")&.text&.strip,
        company_name: card.at_css("[class*='company']")&.text&.strip,
        salary:       card.at_css("[class*='salary']")&.text&.strip,
        location:     card.at_css("[class*='address']")&.text&.strip,
        job_url:      absolute_url(link["href"]),
        posted_at:    nil,
        description:  nil,
        source:       SOURCE
      }
    end

    def absolute_url(href)
      return nil if href.blank?

      href.start_with?("http") ? href : "https://www.vietnamworks.com#{href}"
    end
  end
end
