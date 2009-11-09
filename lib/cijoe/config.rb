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
      git_command = "git config #{config_string}"
      result = `#{git_command} 2>&1`.chomp
      process_status = $?
      
      if successful_command?(process_status) || config_command_with_empty_value?(result,process_status)
        return result
      else
        raise "Error calling git config, is a recent version of git installed? Command: #{git_command}, Error: #{result}"
      end
    end

    def config_string
      @parent ? "#{@parent.config_string}.#{@command}" : @command
    end
    
    private
    
    def successful_command?(process_status)
      process_status.exitstatus.to_i == 0
    end
    
    def config_command_with_empty_value?(result, process_status)
      process_status.exitstatus.to_i == 1 && result.empty?
    end    
  end
end
