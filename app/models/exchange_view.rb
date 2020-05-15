# frozen_string_literal: true

class ExchangeView < ApplicationRecord
  belongs_to :user
  belongs_to :exchange
  belongs_to :post

  self.table_name = "exchange_views"
end
