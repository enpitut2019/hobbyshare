class ApplicationController < ActionController::Base
  before_action :session_check

  def session_check
    @is_session_exists = false
    if session[:login_account_id] == nil
      @is_session_exists = false
      return
    end

    login_account = Account.find_by(id:session[:login_account_id])
    if login_account.is_temp == true
      @is_session_exists = false
    else
      @is_session_exists = true
    end
  end
end
