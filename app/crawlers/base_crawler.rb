
class BaseCrawler
  JOB_KEYS = %i[title company_name salary location
                job_url posted_at description source].freeze

  def crawl(pages: 5)
    (1..pages).flat_map do |page|
      result = fetch_page(page)
      sleep(1)
      result
    end
  end

  private

  def fetch_page(_page)
    raise NotImplementedError, "#{self.class} must implement #fetch_page"
  end
end
