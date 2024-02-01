# frozen_string_literal: true

class RemoveIndexJob < ApplicationJob
  queue_as :default

  def perform(record_class:, id:)
    Sunspot.remove(record_class.safe_deconstantize.new(id:))
  end
end
