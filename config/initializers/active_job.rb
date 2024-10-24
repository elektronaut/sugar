# frozen_string_literal: true

ActiveJob::Base.queue_adapter = :solid_queue

Rails.application.configure do
  MissionControl::Jobs.base_controller_class = "AdminController"
end
