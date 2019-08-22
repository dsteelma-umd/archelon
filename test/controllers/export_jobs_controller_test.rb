# frozen_string_literal: true

require 'test_helper'

class ExportJobsControllerTest < ActionController::TestCase
  setup do
    @cas_user = cas_users(:test_admin)
    mock_cas_login(@cas_user.cas_directory_id)

    # Mock the Stomp client
    stub_const('STOMP_CLIENT', double(Object.new, publish: nil))

    Rails.application.configure do
      config.queues = {
        export_jobs: '/queue/exportjobs',
        export_jobs_completed: '/queue/exportjobs.completed'
      }
    end
  end

  test 'create new export job' do
    expect(STOMP_CLIENT).to receive(:publish)

    assert_difference('ExportJob.count') do
      @cas_user.bookmarks.create({document_id: 'http://example.com/1', document_type: 'SolrDocument'})
      @cas_user.bookmarks.create({document_id: 'http://example.com/2', document_type: 'SolrDocument'})
      params = {}
      params[:export_job] = { name: 'test1', format: 'CSV' }

      post :create, params: params
    end

    assert_redirected_to export_jobs_path
    @cas_user.bookmarks.delete_all
  end

  test 'creating new export job when not connected should raise error' do
    expect(STOMP_CLIENT).to receive(:publish).and_raise(Stomp::Error::NoCurrentConnection.new)

    assert_difference('ExportJob.count') do
      @cas_user.bookmarks.create({document_id: 'http://example.com/1', document_type: 'SolrDocument'})
      @cas_user.bookmarks.create({document_id: 'http://example.com/2', document_type: 'SolrDocument'})
      params = {}
      params[:export_job] = { name: 'test1', format: 'CSV' }

      post :create, params: params
    end
    export_job = ExportJob.last
    assert_equal 'Error', export_job.status

    assert_equal I18n.t(:active_mq_is_down), flash[:error]
    assert_redirected_to export_jobs_path
    @cas_user.bookmarks.delete_all
  end
end
