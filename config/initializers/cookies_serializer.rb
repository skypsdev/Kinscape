# Be sure to restart your server when you modify this file.

# Specify a serializer for the signed and encrypted cookie jars.
# Valid options are :json, :marshal, and :hybrid.
Rails.application.config.action_dispatch.cookies_serializer = :marshal

# TODO: remove this when Rails 6 is stable in production
# If you require your cookies to be read by Rails 5.2 and older, or you are
# still validating your 6.0 deploy and want to be able to rollback set
# Rails.application.config.action_dispatch.use_cookies_with_metadata to false
Rails.application.config.action_dispatch.use_cookies_with_metadata = false
