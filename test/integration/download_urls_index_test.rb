require 'test_helper'

# Integration test for the DownloadUrl index page
class DownloadUrlsIndexTest < ActionDispatch::IntegrationTest
  def setup
    @sort_columns = %w(created_at)
  end

  test 'index including pagination and sorting' do
    get download_urls_path
    assert_template 'download_urls/index'

    # Verify sort links
    assert_select 'a.sort_link', count: @sort_columns.size

    @sort_columns.each do |sort_column|
      %w(asc desc).each do |sort_direction|
        rq_param = { s: sort_column + ' ' + sort_direction }
        get download_urls_path, rq: rq_param
        assert_template 'download_urls/index'
        assert_select 'ul.pagination'

        # Verify sorting by getting the text of the page, then checking the
        # position of each entry -- the position should increase on each entry.
        page = response.body

        last_result_index = 0
        results = DownloadUrl.ransack(rq_param).result.paginate(page: 1)
        results.each do |entry|
          entry_path = download_url_path(entry)
          entry_index = page.index(entry_path)
          assert_not_nil entry_index,
                         "'#{entry_path}' could not be found when sorting '#{sort_column} #{sort_direction}'"
          assert last_result_index < entry_index, "Failed for '#{rq_param[:s]}'"
          assert_select 'tr td a[href=?]', entry_path
          last_result_index = entry_index
        end
      end
    end
  end
end
