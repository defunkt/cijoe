class CIJoe
  module Campfire
    def self.activate
      if File.exist?('campfire.yml')
        require 'tinder'
        @campfire_config = YAML.load_file('campfire.yml')

        CIJoe::Build.class_eval do
          include CIJoe::Campfire
        end
        puts "Loaded Campfire notifier"
      else
        puts "Can't load Campfire notifier."
        puts "Put a campfire.yml in your repo directory with these keys:"
        puts " subdomain, user, pass, and room"
      end
    end

    def notify
      room.speak "#{short_message}. #{commit_url}"
      room.paste full_message if failed?
      room.leave
    end

  private
    def room
      @room ||= begin
        config = @campfire_config
        options = {}
        options[:ssl] = config["use_ssl"] ? true : false
        campfire = Tinder::Campfire.new(config["subdomain"], options)
        campfire.login(config["user"], config["pass"])
        campfire.find_room_by_name(config["room"])
      end
    end

    def short_message
      "Build #{commit.short_identifier} of #{commit.project.name} #{commit.successful? ? "was successful" : "failed"}"
    end

    def full_message
      <<-EOM
Commit Message: #{commit.message}
Commit Date: #{commit.committed_at}
Commit Author: #{commit.author.name}

#{stripped_commit_output}
EOM
    end
  end
end
