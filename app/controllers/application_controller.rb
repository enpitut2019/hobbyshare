class ApplicationController < ActionController::Base
  before_action :session_check

  def session_check
    # ログインしているかどうかを表す変数
    @is_logged_in = false
    # セッションの状態を示す変数 ここでは使わない
    @session_status = ""
    # セッションIDを格納
    @session_id = session[:login_account_id]

    # セッションが存在しない場合
    if @session_id == nil
      @is_logged_in = false
      @session_status = "no_session"
      return
    end

    # セッションのあるアカウントを確認
    @login_account = Account.find_by(id:@session_id)

    # セッションのあるアカウントが消されていた場合
    if @login_account == nil
      @is_logged_in = false
      @session_status = "no_session"
      session[:login_account_id] = nil
      @session_id = nil
      return
    end

    if @login_account.is_temp == true # 仮アカウントの場合
      @is_logged_in = false
      @session_status = "temporary_account"
    else
      @is_logged_in = true
      @session_status = "valid_account"
    end
  end
end
