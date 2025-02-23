# frozen_string_literal: true

module Sugar
  class << self
    def config(_key = nil, *_args)
      @config ||= Configuration.new.tap(&:load)
    end

    def public_browsing?
      config.public_browsing
    end
  end
end
