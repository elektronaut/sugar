# frozen_string_literal: true

class UserLinkResource
  include Alba::Resource

  attributes :id, :label, :name, :url
end
