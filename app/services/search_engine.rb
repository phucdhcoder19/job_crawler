module SearchEngine
  module_function

  def elasticsearch_enabled?
    ENV["ELASTICSEARCH_ENABLED"] == "true"
  end

  def elasticsearch_available?
    return false unless elasticsearch_enabled?

    Job.__elasticsearch__.client.ping
  rescue StandardError
    false
  end
end
