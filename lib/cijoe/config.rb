class CIJoe
  class Config
    def self.method_missing(command, *args)
      new(command)
    end

    def initialize(command, parent = nil)
      @command = command
      @parent = parent
    end

    def method_missing(command, *args)
      Config.new(command, self)
    end

    def to_s
      `git config #{config_string}`.chomp
    end

    def config_string
      @parent ? "#{@parent.config_string}.#{@command}" : @command
    end
  end
end
