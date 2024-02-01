# frozen_string_literal: true

module Searchable
  extend ActiveSupport::Concern

  included do
    after_save :queue_index
    after_destroy :queue_remove_index
  end

  private

  def queue_index
    IndexJob.perform_later(self)
  end

  def queue_remove_index
    RemoveIndexJob.perform_later(record_class: self.class.to_s, id:)
  end
end
