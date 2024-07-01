class TranscribesController < ApplicationController
  before_action :set_video

  def create
    @video.transcribe
    redirect_back_or_to @video, notice: "Transcribing will begin shortly."
  end

  private

  def set_video
    @video = Video.find(params[:video_id])
  end
end
