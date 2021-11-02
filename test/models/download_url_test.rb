# frozen_string_literal: true

require 'test_helper'

class DownloadUrlTest < ActiveSupport::TestCase
  test 'different instances have different tokens' do
    download_url1 = DownloadUrl.new
    download_url1.notes = 'download_url1'
    download_url1.save!

    download_url2 = DownloadUrl.new
    download_url2.notes = 'download_url2'
    download_url2.save!

    assert_not_equal download_url1.token, download_url2.token
  end

  test 'note field must be non-blank' do
    download_url = download_urls(:one)
    assert download_url.valid?

    download_url.notes = nil
    assert_not download_url.valid?

    download_url.notes = ''
    assert_not download_url.valid?

    download_url.notes = 'abc'
    assert download_url.valid?
  end

  test 'expired? should correctly indicate expire status' do
    download_url = download_urls(:one)
    download_url.expires_at = 7.days.from_now
    assert_not download_url.expired?

    download_url.expires_at = 1.second.ago
    assert download_url.expired?
  end

  test 'disables DownloadUrls that have passed their expiration date' do
    expired = create_download_url(7.days.from_now)
    not_expired = create_download_url(21.days.from_now)

    assert expired.enabled?
    assert not_expired.enabled?

    test_date = 14.days.from_now
    DownloadUrl.disable_expired_download_urls(test_date)

    assert_not expired.reload.enabled?
    assert not_expired.reload.enabled?
  end

  test 'disable_expired_download_urls uses current time if no argument is provided' do
    expired_last_week = create_download_url(7.days.ago)
    expired_now = create_download_url(Time.current)
    not_expired = create_download_url(1.minute.from_now)

    DownloadUrl.disable_expired_download_urls

    assert_not expired_last_week.reload.enabled?
    assert_not expired_now.reload.enabled?
    assert not_expired.reload.enabled?
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
