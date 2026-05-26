# Entity Relationship Diagram

Hệ thống hiện có một thực thể chính là `Job`, lưu mỗi tin tuyển dụng
crawl được từ VietnamWorks.

```mermaid
erDiagram
    JOB {
        bigint   id PK         "Khóa chính, tự tăng"
        string   title         "Tiêu đề công việc (NOT NULL)"
        string   company_name  "Tên công ty"
        string   salary        "Mức lương dạng text"
        string   location      "Địa điểm làm việc"
        string   job_url       "URL gốc của tin (NOT NULL, UNIQUE)"
        datetime posted_at      "Ngày đăng tin"
        text     description   "Mô tả công việc"
        string   source        "Nguồn crawl, mặc định 'vietnamworks'"
        datetime created_at     "Thời điểm tạo bản ghi"
        datetime updated_at     "Thời điểm cập nhật gần nhất"
    }
```

## Index

| Cột        | Loại index | Mục đích                                            |
|------------|------------|-----------------------------------------------------|
| `job_url`  | UNIQUE     | Chống trùng lặp — mỗi tin chỉ lưu một lần            |
| `location` | thường     | Tăng tốc filter theo địa điểm                        |
| `posted_at`| thường     | Tăng tốc sort theo tin mới nhất                      |
| `source`   | thường     | Lọc theo nguồn khi về sau crawl thêm nhiều nguồn     |
| `title`    | thường     | Hỗ trợ search theo tiêu đề (LIKE) khi không dùng ES  |

## Ghi chú thiết kế

Hiện tại hệ thống chỉ crawl từ một nguồn nên một bảng `jobs` là đủ.
Trường `source` được giữ lại để mở rộng: nếu sau này crawl thêm các
trang khác (TopCV, ITviec...), dữ liệu vẫn nằm chung một bảng và phân
biệt qua `source`, không cần đổi schema.

Nếu mở rộng lớn hơn, có thể tách `companies` thành bảng riêng và cho
`jobs` tham chiếu `company_id`. Ở phạm vi bài tập, lưu `company_name`
trực tiếp trong `jobs` là hợp lý và đơn giản hơn.
