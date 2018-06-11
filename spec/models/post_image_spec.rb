# frozen_string_literal: true

require "rails_helper"

describe PostImage do
  it { is_expected.to be_a(DynamicImage::Model) }
end
