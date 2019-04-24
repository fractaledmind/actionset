module ActionSet
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  class Configuration
    attr_reader :filters

    def initialize
      @filters = {}
    end

    def register_filter(filter, **options)
      @filters[filter] = options

      self
    end
  end
end
