# frozen_string_literal: true

class IndexJob < ApplicationJob
  queue_as :default

  def perform(*objects)
    Sunspot.index!(objects)
  end
end
