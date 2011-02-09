class CIJoe
  module Campfire
    def self.activate(project_path)
      @project_path = project_path

      if valid_config?
        require 'tinder'

        CIJoe::Build.class_eval do
          include CIJoe::Campfire
        end

        puts "Loaded Campfire notifier"
      elsif ENV['RACK_ENV'] != 'test'
        puts "Can't load Campfire notifier."
        puts "Please add the following to your project's .git/config:"
        puts "[campfire]"
        puts "\ttoken = your_api_token"
        puts "\tsubdomain = whatever"
        puts "\troom = Awesomeness"
        puts "\tssl = false"
      end
    end

    def self.config
      campfire_config = Config.new('campfire', @project_path)
      @config ||= {
        :subdomain => campfire_config.subdomain.to_s,
        :token     => campfire_config.token.to_s,
        :room      => campfire_config.room.to_s,
        :ssl       => campfire_config.ssl.to_s.strip == 'true'
      }
    end

    def self.valid_config?
      %w( subdomain token room ).all? do |key|
        !config[key.intern].empty?
      end
    end

    def notify
      room.speak "#{short_message}. #{commit.url}"
      room.paste full_message if failed?
      room.leave
    end

  private
    def room
      @room ||= begin
        config = Campfire.config
        campfire = Tinder::Campfire.new(config[:subdomain],
            :token => config[:token],
            :ssl => config[:ssl] || false)
        campfire.find_room_by_name(config[:room])
      end
    end

    def short_message
      "#{branch} at #{short_sha} of #{project} " +
        (worked? ? "passed" : "failed") + " (#{duration.to_i}s)"
    end

    def full_message
      <<-EOM
Commit Message: #{commit.message}
Commit Date: #{commit.committed_at}
Commit Author: #{commit.author}

#{clean_output}
EOM
    end
  end
end
