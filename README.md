# Job Crawler System

Hệ thống crawl việc làm từ VietnamWorks, lưu vào database, hiển thị danh
sách cho người dùng, có trang quản trị và tự động crawl mỗi ngày bằng
background job.

## Tính năng

- Crawl việc làm từ VietnamWorks (tối thiểu 5 trang)
- Lưu vào MySQL, chống trùng lặp theo `job_url`
- Trang danh sách việc làm: phân trang, tìm theo tiêu đề, lọc theo địa
  điểm, sắp xếp theo mới nhất
- Trang admin: xem, sửa, xóa, tìm/lọc việc làm
- Background job tự động crawl mỗi ngày lúc 2h sáng (Sidekiq + sidekiq-cron)

## Công nghệ

- Ruby 3.3.6, Rails 8
- MySQL
- Sidekiq + sidekiq-cron (background job)
- Redis (hàng đợi cho Sidekiq)
- HTTParty, Nokogiri (crawler)
- Slim (view), SCSS (style)
- Kaminari (phân trang)

## Yêu cầu môi trường

Máy cần cài sẵn:

- Ruby 3.3.6
- MySQL
- Redis
- Git

## Cài đặt

```bash
# 1. Clone project
git clone <repo-url>
cd job_crawler

# 2. Cài gem
bundle install

# 3. Cấu hình database
# Mở config/database.yml, sửa username/password cho khớp MySQL của bạn

# 4. Tạo database và chạy migration
bin/rails db:create
bin/rails db:migrate

# 5. (Tùy chọn) Nạp dữ liệu mẫu
bin/rails db:seed
```

## Chạy ứng dụng

Cần 3 tiến trình chạy song song, mỗi cái một terminal.

```bash
# Terminal 1 — Redis (trên WSL phải khởi động thủ công mỗi lần)
sudo service redis-server start

# Terminal 2 — Sidekiq (background job)
bundle exec sidekiq

# Terminal 3 — Rails server
bin/rails server
```

Mở trình duyệt:

- `http://localhost:3000` — trang danh sách việc làm
- `http://localhost:3000/admin/jobs` — trang quản trị
- `http://localhost:3000/sidekiq` — dashboard Sidekiq

## Hướng dẫn chạy crawler

### Cách 1 — Chạy thủ công bằng rails runner

```bash
# Crawl 5 trang và lưu vào database
bin/rails runner '
  jobs = VietnamworksCrawler.new.crawl(pages: 5)
  result = JobImporter.call(jobs)
  puts result.summary
'
```

### Cách 2 — Chạy qua background job

```bash
# Đẩy job vào hàng đợi Sidekiq (cần Sidekiq đang chạy)
bin/rails runner 'CrawlJobsJob.perform_later(pages: 5)'
```

### Cách 3 — Tự động hằng ngày

Background job `CrawlJobsJob` được lên lịch chạy mỗi ngày lúc 2h sáng
qua sidekiq-cron (xem `config/schedule.yml`). Lịch tự nạp khi Sidekiq
khởi động.

### Chọn chiến lược crawl

Hệ thống hỗ trợ hai cách crawl, chọn qua biến môi trường `CRAWLER_STRATEGY`:

- `api` (mặc định) — gọi API search nội bộ của VietnamWorks. Ổn định,
  nhanh, trả JSON sạch.
- `html` — dùng headless Chrome render trang rồi parse HTML bằng Nokogiri.

```bash
CRAWLER_STRATEGY=html bin/rails runner 'pp VietnamworksCrawler.new.crawl(pages: 1)'
```

> **Lưu ý về thiết kế crawler:** Trang danh sách việc làm của VietnamWorks
> render bằng JavaScript phía client, nên tải HTML tĩnh không lấy được
> đủ dữ liệu. Vì vậy hệ thống dùng API search nội bộ của chính website
> làm cách mặc định (ổn định, phân trang dễ), đồng thời vẫn có sẵn cách
> parse HTML bằng Nokogiri để đối chiếu.

## Kiến trúc

Logic được tách lớp rõ ràng:

```
app/crawlers/        # Lấy dữ liệu từ nguồn ngoài
  base_crawler.rb        # Interface chung
  vietnamworks_crawler.rb # Chọn strategy theo ENV
  vietnamworks/
    api_strategy.rb      # Crawl qua API
    html_strategy.rb     # Crawl qua HTML (Selenium + Nokogiri)
app/services/        # Logic nghiệp vụ
  job_importer.rb        # Lưu job vào DB, chống trùng theo job_url
app/jobs/            # Background job
  crawl_jobs_job.rb      # Job crawl tự động
```

Luồng hoạt động: `CrawlJobsJob` → `VietnamworksCrawler` (lấy dữ liệu) →
`JobImporter` (lưu vào DB).

## Cấu trúc database

Xem [docs/ERD.md](docs/ERD.md).

## Chạy test

```bash
bundle exec rspec
```

## Khắc phục sự cố

- **Sidekiq lỗi `connection_pool ... wrong number of arguments`**: gem
  `connection_pool` bản 3.x chưa tương thích Sidekiq 7. Đã ghim về bản
  `~> 2.5` trong Gemfile.
- **Redis không kết nối được**: trên WSL, Redis không tự khởi động. Chạy
  `sudo service redis-server start` mỗi khi mở terminal mới.

## Phần bonus (tùy chọn)

<!-- Giữ lại các mục dưới nếu có làm; xóa đi nếu không làm. -->

### Docker

```bash
docker compose up --build
```

### Elasticsearch

Bật tìm kiếm full-text qua biến môi trường `ELASTICSEARCH_ENABLED=true`.
