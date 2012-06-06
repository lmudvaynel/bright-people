class ActivityApproval < ActiveRecord::Base
  belongs_to :expert
  belongs_to :activity

  attr_accessible :expert, :activity

  after_create :approved_activity

  # When expert create approval we marked activity
  # as approved
  def approved_activity
    activity.update_attribute(:approved, true)
  end
end