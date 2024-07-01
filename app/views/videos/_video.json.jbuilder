json.extract! video, :id, :library_id, :guid, :title, :captions, :created_at, :updated_at
json.url video_url(video, format: :json)
