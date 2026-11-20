# frozen_string_literal: true

module Sendio
  # usage api wrapper
  module Usage
    class << self
      # https://developer.send.io/docs/api
      def get
        path = "usage"
        Sendio::Request.new(path, {}, "get").perform
      end
    end
  end
end
