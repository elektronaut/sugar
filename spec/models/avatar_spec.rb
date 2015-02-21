require 'spec_helper'

describe Avatar do
  it { is_expected.to have_one(:user) }
end
