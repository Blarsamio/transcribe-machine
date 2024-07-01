class TranscribeJob < ApplicationJob
  attr_reader :tmp_dir, :video

  def perform(video)
    return if video.nil? || video.captions?

    @video = video
    @tmp_dir = Dir.mktmpdir
    puts @tmp_dir

    download && extract_audio && transcribe && upload_captions

    video.update(captions: true)
  ensure
    FileUtils.remove_entry(tmp_dir) if tmp_dir.present?
  end

  def download
    system "wget -O #{input_path} #{video.download_url}"
  end

  def extract_audio
    system "ffmpeg -i #{input_path} -acodec pcm_s16le -ar 16000 -ac 1 #{audio_path}"
  end

  def transcribe
    system "whisper #{audio_path} --output_format vtt --model medium --output_dir #{tmp_dir}"
  end

  def upload_captions
    unless File.exist?(captions_path)
      Rails.logger.error("Captions file not found: #{captions_path}")
      raise "Transcription failed, captions file not found"
    end

    Bunny.new.upload_captions(guid: video.guid, captions_path: captions_path)
  end

  def input_path
    "#{tmp_dir}/#{video.guid}"
  end

  def audio_path
    input_path + ".wav"
  end

  def captions_path
    input_path + ".vtt"
  end
end
