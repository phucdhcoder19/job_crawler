class Job < ApplicationRecord
  validates :title, presence: true
  validates :job_url, presence: true, uniqueness: true
  validates :source, presence: true

  scope :recent, -> { order(posted_at: :desc) }
  scope :by_location, ->(location) { where(location: location) if location.present? }
  scope :search_title, ->(keyword) { where("title LIKE ?", "%#{keyword}%") if keyword.present? }
  def self.distinct_locations
    where.not(location: [ nil, "" ]).distinct.order(:location).pluck(:location)
  end
end
