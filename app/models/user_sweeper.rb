class UserSweeper < ActionController::Caching::Sweeper
  observe User

  def after_update( user )
    ctrl = ActionController::Base.new
    ctrl.send :expire_action, FakeView.home_url( user_id: user.id, ssl: true )
    ctrl.send :expire_action, FakeView.home_url( user_id: user.id, ssl: false )
  end
end
