class TestSidekiqJob < ApplicationJob
  queue_as :default

  def perform(message)
    # Do something later
    Rails.logger.info "Sidekiq test job ran: #{message}"
  end
end
