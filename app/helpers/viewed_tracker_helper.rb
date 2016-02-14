# encoding: utf-8

module ViewedTrackerHelper
  def viewed_tracker
    @viewed_tracker ||= ViewedTracker.new(current_user)
  end
end
