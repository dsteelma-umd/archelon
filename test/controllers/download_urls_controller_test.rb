require 'test_helper'

class DownloadUrlsControllerTest < ActionController::TestCase
  setup do
    @download_url = download_urls(:one)
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:download_urls)
  end

  test 'should add creator on create' do
    stub_find_solr_document do
      assert_difference('DownloadUrl.count') do
        post :create_download_url, download_url: {
          accessed_at: @download_url.accessed_at,
          download_completed_at: @download_url.download_completed_at,
          enabled: @download_url.enabled, mime_type: @download_url.mime_type,
          notes: @download_url.notes, request_ip: @download_url.request_ip,
          request_user_agent: @download_url.request_user_agent,
          title: @download_url.title,
          url: @download_url.url
        }
      end
    end
    download_url = DownloadUrl.last
    assert_equal session[:cas_user], download_url.creator
  end

  test 'should not be able to set token or creator on create' do
    token_to_try = '12345'
    creator_to_try = 'one'
    stub_find_solr_document do
      assert_difference('DownloadUrl.count') do
        post :create_download_url, download_url: {
          accessed_at: @download_url.accessed_at,
          download_completed_at: @download_url.download_completed_at,
          enabled: @download_url.enabled, mime_type: @download_url.mime_type,
          notes: @download_url.notes, request_ip: @download_url.request_ip,
          request_user_agent: @download_url.request_user_agent,
          title: @download_url.title,
          url: @download_url.url, token: token_to_try, creator: creator_to_try
        }
      end
    end
    download_url = DownloadUrl.last
    assert_not_equal token_to_try, download_url.token
    assert_not_equal creator_to_try, download_url.creator
  end

  test 'should require a note on create' do
    stub_find_solr_document do
      assert_no_difference('DownloadUrl.count') do
        post :create_download_url, download_url: {
          accessed_at: @download_url.accessed_at,
          download_completed_at: @download_url.download_completed_at,
          enabled: @download_url.enabled, mime_type: @download_url.mime_type,
          notes: nil, request_ip: @download_url.request_ip,
          request_user_agent: @download_url.request_user_agent,
          title: @download_url.title,
          url: @download_url.url
        }
      end
    end
  end

  test 'should show download_url' do
    get :show, id: @download_url
    assert_response :success
  end

  test 'generate_download_url should raise 404 RoutingError if document cannot be found' do
    assert_raises(ActionController::RoutingError) do
      get :generate_download_url, document_url: 'document does not exist'
    end
  end

  test 'create_download_url should raise 404 RoutingError if document cannot be found' do
    assert_raises(ActionController::RoutingError) do
      get :create_download_url, document_url: 'document does not exist'
    end
  end

  test 'show_download_url should assign the retrieve url' do
    get :show_download_url, token: @download_url.token
    retrieve_base_url = ENV['RETRIEVE_BASE_URL']
    refute assigns(:download_url).nil?
    assert_equal retrieve_base_url + @download_url.token, assigns(:download_url).retrieve_url
  end

  test 'disable should disable an enabled download_url' do
    assert @download_url.enabled?

    put :disable, token: @download_url.token

    @download_url.reload
    refute @download_url.enabled?
  end

  test 'index should allow filtering by "enabled" status' do
    get :index, rq: { enabled_eq: 1 }

    download_urls = assigns(:download_urls)
    assert download_urls.count > 0
    assert download_urls.all?(&:enabled?)
  end

  test 'index should allow filtering by creator' do
    creator = @download_url.creator
    get :index, rq: { creator_eq: creator }

    download_urls = assigns(:download_urls)
    assert download_urls.count > 0
    assert download_urls.all? { |d| d.creator == creator }
  end

  private

    # Stubs the DownloadUrlsController.find_solr_document call, so that it
    # won't actually make a network call. Returns a sample SolrDocument
    #
    # Usage:
    #
    # stub_find_solr_document do
    #   <Code that calls "find_solr_document">
    # end
    def stub_find_solr_document
      stub_response = SolrDocument.new(
        id: 'http://www.example.com',
        mime_type: 'image/jp2',
        display_title: 'Example'
      )

      @controller.stub :find_solr_document, stub_response do
        yield
      end
    end
end
