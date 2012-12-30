require 'spec_helper'

describe UploadsController do

  it_requires_authentication_for :create
  it_requires_login_for :create

end
