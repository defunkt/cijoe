class CIJoe
  class Build < Struct.new(:user, :project, :started_at, :finished_at, :sha, :status, :output)
    def initialize(*args)
      super
      self.started_at = Time.now
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

    def short_sha
      sha[0,7] if sha
    end

    def clean_output
      output.gsub(/\e[.+?m/, '').strip
    end

    def commit
      @commit ||= Commit.new(sha, user, project)
    end
  end
end
