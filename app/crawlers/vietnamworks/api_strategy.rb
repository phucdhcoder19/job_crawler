
module Vietnamworks
  class ApiStrategy < BaseCrawler
    SOURCE        = "vietnamworks"
    ENDPOINT      = "https://ms.vietnamworks.com/job-search/v1.0/search"
    HITS_PER_PAGE = 50

    RETRIEVE_FIELDS = %w[
      jobId jobTitle jobUrl alias address companyName
      approvedOn salaryMin salaryMax isSalaryVisible
      prettySalary jobDescription
    ].freeze

    private

    def fetch_page(page)
      response = post_search(page - 1)
      raise "VietnamWorks API error HTTP #{response.code}" unless response.code == 200

      body = JSON.parse(response.body)
      Array(body["data"]).map { |raw| normalize(raw) }
    end

    def post_search(api_page)
      HTTParty.post(
        ENDPOINT,
        headers: {
          "Content-Type" => "application/json",
          "Accept"       => "application/json",
          "User-Agent"   => "Mozilla/5.0 (compatible; JobCrawler/1.0)"
        },
        body: {
          userId:         0,
          query:          "",
          filter:         [],
          ranges:         [],
          order:          [],
          hitsPerPage:    HITS_PER_PAGE,
          page:           api_page,
          retrieveFields: RETRIEVE_FIELDS,
          summaryVersion: ""
        }.to_json,
        timeout: 20
      )
    end

    # Chuyển 1 job thô từ API về Hash chuẩn theo JOB_KEYS.
    def normalize(raw)
      {
        title:        raw["jobTitle"],
        company_name: raw["companyName"],
        salary:       format_salary(raw),
        location:     raw["address"],
        job_url:      build_job_url(raw),
        posted_at:    parse_time(raw["approvedOn"]),
        description:  raw["jobDescription"],
        source:       SOURCE
      }
    end

    # Ưu tiên jobUrl từ API; fallback ghép từ alias + jobId
    # để job_url không bao giờ nil (vì nó là khóa chống trùng).
    def build_job_url(raw)
      return raw["jobUrl"] if raw["jobUrl"].present?

      alias_slug = raw["alias"]
      job_id     = raw["jobId"]
      return nil if alias_slug.blank? || job_id.blank?

      "https://www.vietnamworks.com/#{alias_slug}-#{job_id}-jv"
    end

    def format_salary(raw)
      return "Thương lượng" if raw["isSalaryVisible"] == false
      return raw["prettySalary"] if raw["prettySalary"].present?

      min = raw["salaryMin"]
      max = raw["salaryMax"]
      return nil if min.blank? && max.blank?

      [ min, max ].compact.join(" - ")
    end

    def parse_time(value)
      return nil if value.blank?

      Time.zone.parse(value.to_s)
    rescue ArgumentError, TypeError
      nil
    end
  end
end
