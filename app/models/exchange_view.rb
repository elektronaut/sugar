# encoding: utf-8

class ExchangeView < ActiveRecord::Base
  belongs_to :user
  belongs_to :exchange
  belongs_to :post

  self.table_name = "exchange_views"
end
