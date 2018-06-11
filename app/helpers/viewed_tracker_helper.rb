# frozen_string_literal: true

module ViewedTrackerHelper
  def viewed_tracker
    @viewed_tracker ||= ViewedTracker.new(current_user)
  end
end
