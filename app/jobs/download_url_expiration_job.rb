# frozen_string_literal: true

# Disables DownloadUrls that have expired
class DownloadUrlExpirationJob < ApplicationJob
  queue_as :expire_download_urls

  # Disables all enabled DownloadUrls with an expiration date less than or equal
  # to the given time.
  def perform(current_time: Time.current, schedule_next: false)
    schedule_next_run(current_time) if schedule_next

    Rails.logger.debug "Running with current_time=#{current_time}"

    urls_to_expire = DownloadUrl.where(enabled: true).where('expires_at <= ?', current_time)
    if urls_to_expire.any?
      Rails.logger.debug "Disabling #{urls_to_expire.size} expired URLs"
      urls_to_expire.update_all(enabled: false) # rubocop:disable Rails/SkipsModelValidations
    else
      Rails.logger.debug('No URLs have expired.')
    end
  end

  # Schedules the next run based on the given time
  def schedule_next_run(current_time)
    next_run_time = DownloadUrlExpirationJob.time_of_next_run(current_time)
    Rails.logger.debug("Scheduling next run for #{next_run_time}")
    DownloadUrlExpirationJob.set(wait_until: next_run_time).perform_later(schedule_next: true)
  end

  # Returns the time of the next run, based on the given time.
  def self.time_of_next_run(current_time)
    # Run daily at 3:00am
    current_time.tomorrow.change(hour: 3, min: 0)
  end
end
