class RetentionJob < ApplicationJob
  queue_as :default

  def perform(period)
    Action.where("created_at < ?", Time.now.ago(period)).delete_all
  end
end
