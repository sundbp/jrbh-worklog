class Worklog
  def initialize(user_alias)
    @user_alias = user_alias
    @user = User.find_by_alias(user_alias)
  end

  def user
    @user
  end
end

