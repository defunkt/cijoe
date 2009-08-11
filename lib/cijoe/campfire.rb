class CIJoe
  module Campfire
    def self.activate
      if valid_config?
        require 'tinder'

        CIJoe::Build.class_eval do
          include CIJoe::Campfire
        end

        puts "Loaded Campfire notifier"
      else
        puts "Can't load Campfire notifier."
        puts "Please add the following to your project's .git/config:"
        puts "[campfire]"
        puts "\tuser = your@campfire.email"
        puts "\tpass = passw0rd"
        puts "\tsubdomain = whatever"
        puts "\troom = Awesomeness"
        puts "\tssl = false"
      end
    end

    def self.config
      @config ||= {
        :subdomain => Config.campfire.subdomain.to_s,
        :user      => Config.campfire.user.to_s,
        :pass      => Config.campfire.pass.to_s,
        :room      => Config.campfire.room.to_s,
        :ssl       => Config.campfire.ssl.strip == 'true'
      }
    end

    def self.valid_config?
      config.all? { |key, value| !value.empty? }
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
        options = {}
        options[:ssl] = config[:ssl] ? true : false
        campfire = Tinder::Campfire.new(config[:subdomain], options)
        campfire.login(config[:user], config[:pass])
        campfire.find_room_by_name(config[:room])
      end
    end

    def short_message
      "Build #{short_sha} of #{project} #{worked? ? "was successful" : "failed"}"
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
