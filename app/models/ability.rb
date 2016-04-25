class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    user ||= User.new # guest user (not logged in)
    if user.has_role?(:admin)
      can :manage, :all
      can :access, :admin
    elsif user.has_role?(:sales)
      can :read, :all
    else
      can :read, :all
    end

    # apply using folowing inside application
    # if (can? :access, :admin)
    # if (can? :manage, :all)
  end
end
