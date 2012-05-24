class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    # Only specialist should can access to specialist dashboard
    can :access, :specialist_dashboard if user.specialist?
  end
end
