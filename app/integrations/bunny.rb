class Bunny
  attr_reader :client

  def self.sync
    new.sync
  end

  def initialize(access_key: nil, library_id: nil)
    access_key ||= Rails.application.credentials.bunny_access_key
    library_id ||= Rails.application.credentials.bunny_library_id

    @client = BunnyClient.new(access_key: access_key, library_id: library_id)
  end

  def sync(page: 1, per_page: 100)
    loop do
      response = client.videos(page: page, per_page: per_page)
      Video.transaction do
        response[:items].each{ sync_video(_1) }
      end
      next_page = response[:currentPage] * response[:itemsPerPage] < response[:totalItems]
      break unless next_page
      page += 1
    end
  end

  def sync_video(item)
    video = Video.where(guid: item[:guid]).first_or_initialize
    video.update(
      library_id: item[:videoLibraryId],
      title: item[:title],
      views_count: item[:views],
      thumbnail_filename: item[:thumbnailFileName],
      captions: item[:captions].any?{ _1[:label] == "English"}
    )
  end

  def upload_captions(guid:, captions_path:)
    content = Base64.strict_encode64(File.read(captions_path))
    client.post("/videos/#{guid}/captions/en", body: {srclang: "en", label: "English", captionsFile: content})
  end
end
