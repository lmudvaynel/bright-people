BrightPeople::Application.configure do
  config.cache_classes = true
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true
  config.serve_static_assets = false
  config.assets.compress = true
  config.assets.compile = false
  config.assets.digest = true
  config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect'
  config.assets.precompile += %w( admin/active_admin.js admin/active_admin.css chosen.jquery.min.js dashboard/activities.js)
  config.i18n.fallbacks = true
  config.active_support.deprecation = :notify
end