class SyncsController < ApplicationController
  def create
    SyncJob.perform_later
    redirect_back_or_to root_path, notice: "Syncing will begin shortly"
  end
end
