Airbrake.configure do |config|
  config.project_id = Global.airbrake.project_id
  config.project_key = Global.airbrake.project_key
  config.environment = Rails.env.to_s
  config.ignore_environments = [:development, :test]
end

Airbrake.add_filter do |notice|
  if notice[:errors].any? { |error| error[:type] == 'SignalException' }
    notice.ignore!
  end
end
