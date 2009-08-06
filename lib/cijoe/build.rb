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

    class Commit < Struct.new(:sha, :user, :project)
      def url
        "http://github.com/#{user}/#{project}/commit/#{sha}"
      end

      def author
        raw_commit_lines[1].split(':')[-1]
      end

      def committed_at
        raw_commit_lines[2].split(':', 2)[-1]
      end

      def message
        raw_commit_lines[4].split(':')[-1].strip
      end

      def raw_commit
        @raw_commit ||= `git show #{sha}`.chomp
      end

      def raw_commit_lines
        @raw_commit_lines ||= raw_commit.split("\n")
      end
    end
  end
end
