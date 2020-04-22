class ExportJobRelayJob < ApplicationJob
  def perform(export_job)
    ActionCable.server.broadcast "export_jobs:status",
      export_job: export_job, message: render_message(export_job)
#      export_job: ExportJobsController.render(partial: 'export_jobs/export_job', locals: { export_job: export_job })
  end

  def render_message(export_job)
    ApplicationController.renderer.render(partial: 'export_jobs/export_job_status', locals: { export_job: export_job})
  end
end