class CrawlJobsJob < ApplicationJob
  queue_as :default

  def perform(pages: 5)
    Rails.logger.info("[CrawlJobsJob] Bắt đầu crawl #{pages} trang...")

    raw_jobs = VietnamworksCrawler.new.crawl(pages: pages)
    result   = JobImporter.call(raw_jobs)

    Rails.logger.info("[CrawlJobsJob] Hoàn tất. #{result.summary}")
    result
  end
end
