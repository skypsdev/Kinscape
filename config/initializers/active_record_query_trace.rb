if Rails.env.development? || Rails.env.staging? || Rails.env.test?
  ActiveRecordQueryTrace.enabled = true
  ActiveRecordQueryTrace.lines = 10
  ActiveRecordQueryTrace.colorize = :light_purple
end
