class Job < ApplicationRecord
  validates :title, presence: true
  validates :job_url, presence: true, uniqueness: true
  validates :source, presence: true

  scope :recent, -> { order(posted_at: :desc) }
  scope :by_location, ->(location) { where(location: location) }
  scope :search_title, ->(keyword) { where("title ILIKE ?", "%#{keyword}%") }
end
