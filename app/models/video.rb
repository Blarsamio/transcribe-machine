class Video < ApplicationRecord
  scope :captioned, ->{ where(captions: true) }
  scope :uncaptioned, ->{ where(captions: false) }

  broadcasts_refreshes
  after_commit :transcribe, on: [:create, :update], unless: :captions?

  def download_url
    "https://#{Rails.application.credentials.bunny_zone}.b-cdn.net/#{guid}/play_240p.mp4"
  end

  def thumbnail_url
    "https://#{Rails.application.credentials.bunny_zone}.b-cdn.net/#{guid}/#{thumbnail_filename}"
  end

  def transcribe
    TranscribeJob.perform_later(self)
  end
end
