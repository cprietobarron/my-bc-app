# frozen_string_literal: true

# Protect against timing attacks:
# - See https://codahale.com/a-lesson-in-timing-attacks/
# - See https://thisdata.com/blog/timing-attacks-against-string-comparison/
# - Use & (do not use &&) so that it doesn't short circuit.
# - Use digests to stop length information leaking (see also ActiveSupport::SecurityUtils.variable_size_secure_compare)
SECURE_COMPARE = ->(username, password) do
  admin_usr_sha = ::Digest::SHA256.hexdigest(Rails.configuration.x.admin.username)
  admin_pwd_sha = ::Digest::SHA256.hexdigest(Rails.configuration.x.admin.password)
  user = ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(username), admin_usr_sha)
  pass = ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(password), admin_pwd_sha)
  user & pass
end

require "sidekiq/web"
require "sidekiq-scheduler/web"

Sidekiq::Web.use(Rack::Auth::Basic, &SECURE_COMPARE) if Rails.env.production?
mount Sidekiq::Web, at: "/sidekiq"

flipper_app = Flipper::UI.app(Flipper.instance) do |builder|
  builder.use(Rack::Auth::Basic, &SECURE_COMPARE) if Rails.env.production?
end
mount flipper_app => "/flipper"
