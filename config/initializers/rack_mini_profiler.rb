if Rails.env == 'development' && defined? Rack::MiniProfiler
  Rack::MiniProfiler.config.storage = Rack::MiniProfiler::MemoryStore
end
