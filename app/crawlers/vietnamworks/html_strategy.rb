module Vietnamworks
  class HtmlStrategy < BaseCrawler
    SOURCE   = "vietnamworks"
    BASE_URL = "https://www.vietnamworks.com/viec-lam"

    private

    def fetch_page(page)
      require "selenium-webdriver"

      html = render_page(page)
      doc  = Nokogiri::HTML(html)

      cards = doc.css(".search_list.view_job_item")

      cards.map do |card|
        normalize(card)
      end.compact
    end

    def render_page(page)
      driver = build_driver
      url = "#{BASE_URL}?page=#{page}"

      puts "Opening: #{url}"

      driver.navigate.to(url)
      sleep 10
      puts "Title: #{driver.title}"
      puts "Current URL: #{driver.current_url}"
      wait = Selenium::WebDriver::Wait.new(timeout: 30)
      wait.until { driver.find_elements(css: ".search_list.view_job_item").any? }

      puts "Title: #{driver.title}"
      puts "Current URL: #{driver.current_url}"

      html = driver.page_source
      html
    ensure
      driver&.quit
    end

    def build_driver
      options = Selenium::WebDriver::Options.chrome
      options.add_argument("--headless=new")
      options.add_argument("--no-sandbox")
      options.add_argument("--disable-dev-shm-usage")
      options.add_argument("--disable-gpu")
      options.add_argument("--window-size=1920,1080")
      options.add_argument("--disable-blink-features=AutomationControlled")
      options.add_argument("--user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36")
      options.binary = "/usr/bin/chromium" if File.exist?("/usr/bin/chromium")
      options.binary = "/usr/bin/chromium-browser" if File.exist?("/usr/bin/chromium-browser")
      options.binary = "/usr/bin/google-chrome" if File.exist?("/usr/bin/google-chrome")

       remote_url = ENV["SELENIUM_REMOTE_URL"]

      if remote_url.present?
        Selenium::WebDriver.for(
          :remote,
          url: remote_url,
          capabilities: options
        )
      else
        Selenium::WebDriver.for(
          :chrome,
          options: options
        )
      end
    end

    def normalize(card)
      link = card.at_css("a[href*='-jv']")
      return nil if link.nil?


      company_link = card.at_css("a[href*='/nha-tuyen-dung/']")

      href = link.attribute("href")&.value
      text = card.text.gsub(/\s+/, " ").strip
      salary = extract_salary(text)
      location = extract_location(text)
      title = extract_title(text, salary, location)
      company_name = company_link&.attribute("title")&.value || company_link&.text&.strip
      puts "Normalizing job: #{text}"

      {
        title:        title,
        company_name: company_name,
        salary:       extract_salary(text),
        location:     extract_location(text),
        job_url:      absolute_url(href),
        posted_at:    nil,
        description:  nil,
        source:       SOURCE
      }
    end

    def absolute_url(href)
      return nil if href.blank?

      href.start_with?("http") ? href : "https://www.vietnamworks.com#{href}"
    end

    def extract_salary(text)
      text.match(/(Thương lượng|Từ\s+\d+tr\s+₫\/tháng|\d+tr-\d+tr\s+₫\/tháng|\$ ?[\d,]+(?:-\d+,?[\d]*)? ?\/tháng)/i)&.to_s
    end

    def extract_location(text)
      locations = [
        "Hà Nội",
        "Hồ Chí Minh",
        "Đà Nẵng",
        "Bắc Ninh",
        "Hưng Yên",
        "Quảng Ninh"
      ]

      locations.select { |location| text.include?(location) }.join(", ")
    end

    def extract_company(text)
      salary = extract_salary(text)
      return nil if salary.nil?

      before_salary = text.split(salary).first
      before_salary.sub(/^Mới\s*/, "").strip
    end

    def extract_title(text, salary, location)
      title = text.dup
      title.gsub!(salary, "") if salary
      title.gsub!(location, "") if location
      title.strip!
      title.empty? ? nil : title
    end
  end
end
