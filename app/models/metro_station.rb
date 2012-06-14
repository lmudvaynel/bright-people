class MetroStation < ActiveRecord::Base
  has_many :organizations
  has_many :activities

  attr_accessible :title, as: :admin
end
