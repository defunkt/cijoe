require 'yaml'

class CIJoe
  class Build < Struct.new(:project_path, :user, :project, :started_at, :finished_at, :sha, :status, :output, :pid, :branch)
    def initialize(*args)
      super
      self.started_at ||= Time.now
    end

    def status
      return super if started_at && finished_at
      :building
    end

    def failed?
      status == :failed
    end

    def worked?
      status == :worked
    end

    def building?
      status == :building
    end

    def duration
      return if building?
      finished_at - started_at
    end

    def short_sha
      if sha
        sha[0,7]
      else
        "<unknown>"
      end
    end

    def clean_output
      output.gsub(/\e\[.+?m/, '').strip
    end

    def env_output
      out = clean_output
      out.size > 100_000 ? out[-100_000,100_000] : out
    end

    def commit
      return if sha.nil?
      @commit ||= Commit.new(sha, user, project, project_path)
    end

    def dump(file)
      config = [user, project, started_at, finished_at, sha, status, output, pid, branch]
      data = YAML.dump(config)
      File.open(file, 'wb') { |io| io.write(data) }
    end

    def self.load(file, project_path)
      if File.exist?(file)
        config = YAML.load(File.read(file)).unshift(project_path)
        new *config
      end
    end
  end
end
