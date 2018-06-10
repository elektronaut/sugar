# frozen_string_literal: true

require "rails_helper"

describe Avatar do
  it { is_expected.to have_one(:user) }
end
