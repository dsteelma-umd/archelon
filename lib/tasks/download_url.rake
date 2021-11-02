namespace :download_url do
  desc 'Disable expired DownloadUrls'
  task disable_expired_download_urls: :environment do
    task_name = 'download_url:disable_expired_download_urls'
    current_time = Time.current
    urls_to_expire = DownloadUrl.where(enabled: true).where('expires_at <= ?', current_time)
    if urls_to_expire.any?
      Rails.logger.debug "#{task_name}: Disabling #{urls_to_expire.size} expired URLs"
      urls_to_expire.update_all(enabled: false) # rubocop:disable Rails/SkipsModelValidations
    else
      Rails.logger.debug("#{task_name}: No URLs have expired.")
    end
  end
end
