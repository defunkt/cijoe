class CIJoe
  # An in memory queue used for maintaining an order list of requested
  # builds.
  class Queue
    # enabled - determines whether builds should be queued or not.
    def initialize(enabled)
      @enabled = enabled
      @queue = []
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
      @queue << branch unless @queue.include? branch
    end

    # Returns a String of the next branch to build
    def next_branch_to_build
      @queue.shift
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
    def enabled?
      @enabled
    end
  end
end
