module Prrr
  class Logger < ::Logger
    def initialize
      super('/proc/1/fd/1')
    end
  end
end
