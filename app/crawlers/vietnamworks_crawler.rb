
class VietnamworksCrawler
  STRATEGIES = {
    "api"  => Vietnamworks::ApiStrategy,
    "html" => Vietnamworks::HtmlStrategy
  }.freeze

  def initialize(strategy: ENV.fetch("CRAWLER_STRATEGY", "html"))
    klass = STRATEGIES.fetch(strategy) do
      raise ArgumentError, "Strategy is not valid #{strategy}"
    end
    @strategy = klass.new
  end

  def crawl(pages: 5)
    @strategy.crawl(pages: pages)
  end
end
