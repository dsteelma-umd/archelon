# frozen_string_literal: true

require 'test_helper'

class DownloadUrlExpirationJobTest < ActiveJob::TestCase
  test 'disables DownloadUrls that have passed their expiration date' do
    expired = create_download_url(7.days.from_now)
    not_expired = create_download_url(21.days.from_now)

    assert expired.enabled?
    assert not_expired.enabled?

    test_date = 14.days.from_now
    DownloadUrlExpirationJob.perform_now(current_time: test_date)

    assert_not expired.reload.enabled?
    assert not_expired.reload.enabled?
  end

  test 'uses current time if no argument is provided' do
    expired_last_week = create_download_url(7.days.ago)
    expired_now = create_download_url(Time.current)
    not_expired = create_download_url(1.minute.from_now)

    DownloadUrlExpirationJob.perform_now

    assert_not expired_last_week.reload.enabled?
    assert_not expired_now.reload.enabled?
    assert not_expired.reload.enabled?
  end

  test 'does not schedule next run by default' do
    assert_no_enqueued_jobs do
      DownloadUrlExpirationJob.new.perform(current_time: Time.current)
    end
  end

  test 'schedules next run by default if requested' do
    current_time = Time.current
    next_run_time = DownloadUrlExpirationJob.time_of_next_run(current_time)
    assert_enqueued_with(job: DownloadUrlExpirationJob, at: next_run_time) do
      DownloadUrlExpirationJob.new.perform(current_time: current_time, schedule_next: true)
    end
  end

  def create_download_url(expiration_time)
    download_url = DownloadUrl.new
    download_url.enabled = true
    download_url.notes = "Expires at #{expiration_time}"
    download_url.expires_at = expiration_time
    download_url.save!
    download_url
  end
end
