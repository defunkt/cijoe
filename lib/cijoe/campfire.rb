class CIJoe
  class Campfire
    attr_reader :project_path, :build
    
    def initialize(project_path)
      @project_path = project_path
      if valid?
        require 'tinder'
        puts "Loaded Campfire notifier for #{project_path}."
      elsif ENV['RACK_ENV'] != 'test'
        puts "Can't load Campfire notifier for #{project_path}."
        puts "Please add the following to your project's .git/config:"
        puts "[campfire]"
        puts "\ttoken = abcd1234"
        puts "\tsubdomain = whatever"
        puts "\troom = Awesomeness"
        puts "\tssl = false"
      end
    end
    
    def campfire_config
      campfire_config = Config.new('campfire', project_path)
      @config = {
        :subdomain => campfire_config.subdomain.to_s,
        :token     => campfire_config.token.to_s,
        :room      => campfire_config.room.to_s,
        :ssl       => campfire_config.ssl.to_s.strip == 'true'
      }
    end

    def valid?
      %w( subdomain token room ).all? do |key|
        !campfire_config[key.intern].empty?
      end
    end

    def notify(build)
      begin
        @build = build
        room.speak "#{short_message}. #{build.commit.url}"
        room.paste full_message if build.failed?
        room.leave
      rescue
        puts "Please check your campfire config for #{project_path}."
      end
    end

  private
    def room
      @room ||= begin
        config = campfire_config
        campfire = Tinder::Campfire.new(config[:subdomain],
            :token => config[:token],
            :ssl => config[:ssl] || false)
        campfire.find_room_by_name(config[:room])
      end
    end

    def short_message
      "#{build.branch} at #{build.short_sha} of #{build.project} " +
        (build.worked? ? "passed" : "failed") + " (#{build.duration.to_i}s)"
    end

    def full_message
      <<-EOM
Commit Message: #{build.commit.message}
Commit Date: #{build.commit.committed_at}
Commit Author: #{build.commit.author}

#{build.clean_output}
EOM
    end
  end
end
