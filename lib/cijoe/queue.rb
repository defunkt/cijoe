class CIJoe
  # An in memory queue used for maintaining an order list of requested
  # builds.
  class Queue
    # enabled - determines whether builds should be queued or not.
    def initialize(enabled, verbose=false)
      @enabled = enabled
      @verbose = verbose
      @queue = []

      log("Build queueing enabled") if enabled
    end

    # Public: Appends a branch to be built, unless it already exists
    # within the queue.
    #
    # branch - the name of the branch to build or nil if the default
    #         should be built.
    #
    # Returns nothing
    def append_unless_already_exists(branch)
      return unless enabled?
      unless @queue.include? branch
        @queue << branch
        log "#{Time.now.to_i}: Queueing #{branch}"
      end
    end

    # Returns a String of the next branch to build
    def next_branch_to_build
      branch = @queue.shift
      log "#{Time.now.to_i}: De-queueing #{branch}"
      branch
    end

    # Returns true if there are requested builds waiting and false
    # otherwise.
    def waiting?
      if enabled?
        not @queue.empty?
      else
        false
      end
    end

  protected
    def log(msg)
      puts msg if @verbose
    end

    def enabled?
      @enabled
    end
  end
end
