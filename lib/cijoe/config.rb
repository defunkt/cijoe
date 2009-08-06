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
      command = @parent ? "#{@parent}.#{@command}" : @command
      `git config #{command}`.chomp
    end
  end
end
