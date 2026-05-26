puts "Bắt đầu seed dữ liệu từ VietnamWorks..."

begin
  raw_jobs = VietnamworksCrawler.new.crawl(pages: 2)
  result   = JobImporter.call(raw_jobs)

  puts "Seed hoàn tất. #{result.summary}"
  puts "Tổng số job trong database: #{Job.count}"
rescue => e
  puts "Seed thất bại: #{e.message}"
  puts "Có thể do mất mạng hoặc API VietnamWorks thay đổi."
end
