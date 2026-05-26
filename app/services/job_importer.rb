class JobImporter
  Result = Struct.new(:created, :updated, :skipped, keyword_init: true) do
    def summary
      "Tạo mới: #{created}, Cập nhật: #{updated}, Bỏ qua: #{skipped}"
    end
  end

  def initialize(raw_jobs)
    @raw_jobs = raw_jobs
  end

  def self.call(raw_jobs)
    new(raw_jobs).call
  end

  def call
    result = Result.new(created: 0, updated: 0, skipped: 0)

    @raw_jobs.each do |attrs|
      import_one(attrs, result)
    end

    result
  end

  private

  def import_one(attrs, result)
    job_url = attrs[:job_url]
    if job_url.blank?
      result.skipped += 1
      return
    end

    job = Job.find_or_initialize_by(job_url: job_url)
    was_new = job.new_record?

    job.assign_attributes(cleaned_attributes(attrs))

    if job.save
      was_new ? result.created += 1 : result.updated += 1
    else
      Rails.logger.warn("[JobImporter] Bỏ qua job lỗi: #{job.errors.full_messages.join(', ')}")
      result.skipped += 1
    end
  end

  def cleaned_attributes(attrs)
    attrs.merge(
      description: strip_html(attrs[:description])
    )
  end

  def strip_html(html)
    return nil if html.blank?

    ActionView::Base.full_sanitizer.sanitize(html).squish
  end
end
