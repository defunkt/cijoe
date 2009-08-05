class CIJoe
  class Build < Struct.new(:started_at, :sha, :finished_at, :status, :output)
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

    def started_at
      super.strftime(date_format) if super
    end

    def finished_at
      super.strftime(date_format) if super
    end

    def short_sha
      sha[0,7] if sha
    end

    def date_format
      "%Y-%m-%d %H:%M"
    end

    # notifiers should override this
    def notify
    end
  end
end
