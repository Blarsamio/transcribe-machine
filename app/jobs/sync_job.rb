class SyncJob < ApplicationJob
  def perform
    Bunny.sync
  end
end
