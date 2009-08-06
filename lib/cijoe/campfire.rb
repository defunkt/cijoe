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
      end
    end

    def self.config
      @config ||= {
        :subdomain => Config.campfire.subdomain,
        :user      => Config.campfire.user,
        :pass      => Config.campfire.pass,
        :room      => Config.campfire.room,
      }
    end

    def self.valid_config?
      (config.keys & [ :subdomain, :user, :pass, :room ]).size == 4
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
        options[:ssl] = config["use_ssl"] ? true : false
        campfire = Tinder::Campfire.new(config["subdomain"], options)
        campfire.login(config["user"], config["pass"])
        campfire.find_room_by_name(config["room"])
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
