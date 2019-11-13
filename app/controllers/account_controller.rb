class AccountController < ApplicationController

  def sign_up
  end

  def mypage
    # ログインしていない場合や仮アカウントの場合は弾く
    if @session_status == "no_session" || @session_status == "temporary_account"
      flash[:notice] = "まだログインしていません！"
      redirect_to("/")
      return
    end

    @account_name = @login_account.name
    @dummy_user_id = @login_account.user_id
    @users = User.where(account_id: @login_account.id)
  end

  def new_account
    if Account.find_by(name: params[:name])
      flash[:notice] = "その名前はすでに使われています"#nameが既存のものと一致した場合は弾く
      redirect_to("/account/sign_up")
      return
    end

    # セッションがない場合
    if @session_status == "no_session"
      # アカウントを作成
     ac = Account.create(name: params[:name], password: params[:password])
      # dummy_userを設定
     dummy_user = User.create()
     ac.update(user_id: dummy_user.id)
     # セッションを書き換え
     session[:login_account_id] = ac.id
     # マイページへ飛ばす
     flash[:notice] = "アカウントを作成しました！"
     redirect_to("/account/#{ac.id}")
    # セッションがある場合
    else
      # 既に別のアカウントでログインしている場合
      if @session_status == "valid_account"
        # トップページへ戻す
        flash[:notice] = "既に別のアカウントでログインしています！"
        redirect_to("/")
      else # ログインしているのは仮アカウントだった場合
        # name,passwordの設定
        @login_account.name = params[:name]
        @login_account.password = params[:password]
        # dummy_userの作成
        dummy_user = User.create()
        @login_account.user_id = dummy_user.id
        # 仮アカウントから本アカウント扱いに変更
        @login_account.is_temp = false
        #変更を保存
        @login_account.save
        # マイページへリダイレクト
        flash[:notice] = "アカウントを作成しました！"
        redirect_to("/account/#{@login_account.id}")
      end
    end
  end

  def login_process
    # ログインしようとしているアカウント
    target_account = Account.find_by(name: params[:name])

    if target_account&.is_temp || !target_account&.authenticate(params[:password])
      #仮アカウントだったりパスワードが違う場合は弾く
      flash[:notice] = "入力された内容に誤りがあります"
      redirect_to("/account/login")
      return
    else
      #今はログインしていない場合
      if @session_status == "no_session"
        session[:login_account_id] = target_account.id
        flash[:notice] = "ログインしました！"
        redirect_to("/account/#{target_account.id}")
        return
      else
        # 別の本アカウントでログインしている場合
        if @session_status == "valid_account"
          flash[:notice] = "既に別のアカウントでログインしています"
          redirect_to("/")
        # 仮アカウントが発行されている場合
        else
          # 仮アカウントに紐付けられているユーザーを本アカウントに紐付け直す
          User.where(account_id: @session_id).update(account_id: target_account.id)
          # 仮アカウントを削除
          @login_account.destroy()
          # セッションを本アカウントに変更し、マイページに飛ばす
          session[:login_account_id] = target_account.id
          flash[:notice] = "ログインしました！"
          redirect_to("/account/#{target_account.id}")
        end
      end
    end
  end

  def login
  end

  def logout
    if @session_status == "no_session"
      flash[:notice] = "まだログインしていません！"
      redirect_to("/")
    else
      if @session_status == "temporary_account"
        flash[:notice] = "まだログインしていません"
        #仮アカウントからログアウトすべきかは微妙
        session[:login_account_id] = nil
        redirect_to("/")
      else #本アカウントの場合
        session[:login_account_id] = nil
        flash[:notice] = "ログアウトしました"
        redirect_to("/")
      end
    end
  end

end
