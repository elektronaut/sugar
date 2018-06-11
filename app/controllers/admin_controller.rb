# frozen_string_literal: true

class AdminController < ApplicationController
  requires_admin
end
