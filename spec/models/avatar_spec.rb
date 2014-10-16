require 'spec_helper'

describe Avatar do
  it { should have_one(:user) }
end
