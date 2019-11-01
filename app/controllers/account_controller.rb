class AccountController < ApplicationController

  def sign_up
  end

  def mypage
    session_id = session[:login_account_id].to_i
    @account_name = Account.find_by(id: session[:login_account_id]).name
  end

  def new_account
    session_id = session[:login_account_id]
    if Account.find_by(name: params[:name])
      flash[:notice] = "その名前はすでに使われています"#nameが既存のものと一致した場合は弾く
      redirect_to("/account/sign_up")
    end

    # セッションがない場合
    if session_id == nil
      # アカウントを作成
     ac = Account.create(name: params[:name], password: params[:password])
      # dummy_userを設定
     dummy_user = User.create()
     ac.user_id = dummy_user.id
     # セッションを書き換え
     session[:login_account_id] = ac.id
     # マイページへ飛ばす
     flash[:notice] = "アカウントを作成しました！"
     redirect_to("/account/#{ac.id}")
    else
      # セッションがあるのでログインしているアカウントを取り出す
      login_account = Account.find_by(id:session_id)
      # 既に別のアカウントでログインしている場合
      if login_account.is_temp == false
        # トップページへ戻す
        flash[:notice] = "既に別のアカウントでログインしています！"
        redirect_to("/")
      # ログインしているのは仮アカウントだった場合
      else
        # name,passwordの設定
        login_account.name = params[:name]
        login_account.password = params[:password]
        # dummy_userの作成
        dummy_user = User.create()
        login_account.user_id = dummy_user.id
        # 仮アカウントから本アカウント扱いに変更
        login_account.is_temp = false
        # マイページへリダイレクト
        flash[:notice] = "アカウントを作成しました！"
        redirect_to("/account/#{login_account.id}")
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
    else
      session_id = session[:login_account_id]
      #今はログインしていない場合
      if session_id == nil
      session[:login_account_id] = target_account.id
      flash[:notice] = "ログインしました！"
      redirect_to("/account/#{target_account.id}")
      else
        session_account = Account.find_by(id:session_id)
        if session_account.is_temp = false
          flash[:notice] = "既に別のアカウントでログインしています"
          redirect_to("/")
        else
          User.where(account_id: session_account).each do |u|
            u.account_id = target_account
          end
          session_accout.dedtroy()
          session[:login_account_id] = target_account
          flash[:notice] = "ログインしました！"
          redirect_to("/account/#{target_account.id}")
        end
      end

    end
  end

  def login
  end

  def logout
    if !session[:login_account_id]
      flash[:notice] = "まだログインしていません！"
      redirect_to("/")
    else
      login_account = Account.find_by(id:session[:login_account_id])
      if login_account.is_temp = true
        flash[:notice] = "まだログインしていません"
        #仮アカウントからログアウトすべきかは微妙
        session[:login_account_id] = nil
        redirect_to("/")
      else
        session[:login_account_id] = nil
        flash[:notice] = "ログアウトしました"
        redirect_to("/")
      end
    end
  end

end
