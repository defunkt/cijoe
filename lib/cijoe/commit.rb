class CIJoe
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
