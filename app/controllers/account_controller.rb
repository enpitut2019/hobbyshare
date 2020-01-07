class AccountController < ApplicationController

  def sign_up
    # アカウント名の初期値.作成失敗で戻ってくる場合に入力内容を引き継ぐために使う.
    @account_name = ""
  end

  def mypage
    # ログインしていない場合や仮アカウントの場合は弾く
    if @session_status == "no_session" || @session_status == "temporary_account"
      flash[:notice] = "まだログインしていません！"
      redirect_to("/")
      return
    end

    @account_name = @login_account.name
    dummy_user_id = @login_account.user_id
    dummy_user = User.find_by(id: dummy_user_id)
    @dummy_user_token = dummy_user.token
    @users = User.where(account_id: @login_account.id)
    @account_id = @login_account.id



    #ユーザの趣味を取得して変数に入れる
    @uhobby_record = UserHobby.where(user_id: dummy_user_id).order(:id)
    #uhobby_recordからhobbyIDだけを取り出して配列にする
    @hobbies_id = []
    @has_alias = []
    has_alias_id = [] #別名を持つ趣味
    @uhobby_record.each do |record|
      @hobbies_id.push(record.hobby_id)
      if record.similar_hobbies_id != nil
        @has_alias.push(true)
        has_alias_id.push(record.similar_hobbies_id)
      else
        @has_alias.push(false)
      end
    end
    #HobbyIDに対応するレコードを取ってくる
    @users_hobbies = []
    @hobbies_id.each do |hid|
      @users_hobbies.push(Hobby.find_by(id: hid))
    end
    #趣味の別名の配列を配列にする
    @alias_names_queue = []
    @alias_ids_queue = []
    has_alias_id.each do |alias_id|
      alias_ids = []
      alias_names = []
      while alias_id != nil do
        alias_ids.push(alias_id)
        has_alias = SimilarHobby.find_by(id: alias_id)
        alias_names.push(Hobby.find_by(id: has_alias.hobby_id).hobby_name)
        alias_id = has_alias.next
      end
      @alias_ids_queue.push(alias_ids)
      @alias_names_queue.push(alias_names)
    end

  end

  def new_account
    if Account.find_by(name: params[:name])
      flash[:notice] = "その名前はすでに使われています"#nameが既存のものと一致した場合は弾く
      @account_name = params[:name] #入力内容の引継ぎ
      render("sign_up")
      return
    end

    # セッションがない場合
    if @session_status == "no_session"
      # アカウントを作成
     ac = Account.create(name: params[:name], password: params[:password])
      # dummy_userを設定
     dummy_user = User.create(token:SecureRandom.urlsafe_base64, opentoken:SecureRandom.urlsafe_base64)
     ac.update(user_id: dummy_user.id)
     # セッションを書き換え
     session[:login_account_id] = ac.id
     # マイページへ飛ばす
     flash[:notice] = "アカウントを作成しました！"
     redirect_to("/account/mypage")
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
        dummy_user = User.create(token:SecureRandom.urlsafe_base64, opentoken:SecureRandom.urlsafe_base64)
        @login_account.user_id = dummy_user.id
        # 仮アカウントから本アカウント扱いに変更
        @login_account.is_temp = false
        #変更を保存
        @login_account.save
        # マイページへリダイレクト
        flash[:notice] = "アカウントを作成しました！"
        redirect_to("/account/mypage")
      end
    end
  end

  def login_process
    # ログインしようとしているアカウント
    target_account = Account.find_by(name: params[:name])

    if target_account&.is_temp || !target_account&.authenticate(params[:password])
      #仮アカウントだったりパスワードが違う場合は弾く
      flash[:notice] = "入力された内容に誤りがあります"
      @account_name = params[:name] #入力内容の引継ぎ
      render("login")
      return
    else
      #今はログインしていない場合
      if @session_status == "no_session"
        session[:login_account_id] = target_account.id
        flash[:notice] = "ログインしました！"
        redirect_to("/account/mypage")
        return
      else
        # 別の本アカウントでログインしている場合
        if @session_status == "valid_account"
          flash[:notice] = "既に別のアカウントでログインしています"
          redirect_to("/")
        # 仮アカウントが発行されている場合
        else
          # 仮アカウントと本アカウントにそれぞれ紐づけられているユーザー
          temporary_account_users = User.where(account_id: @session_id)
          valid_account_users = User.where(account_id: target_account.id)
          # それぞれのユーザーの所属しているグループのIDの配列
          temporary_account_users_groups = temporary_account_users.pluck(:group_id)
          valid_account_users_groups = valid_account_users.pluck(:group_id)
          # 重複しているものを取り出す
          duplications = temporary_account_users_groups & valid_account_users_groups

          # 仮アカウントに紐付けられているユーザーを本アカウントに紐付け直す
          temporary_account_users.update(account_id: target_account.id)
          # 仮アカウントを削除
          @login_account.destroy()
          # セッションを本アカウントに変更
          session[:login_account_id] = target_account.id

          # 重複がない場合はログイン通知
          if duplications.empty?
            flash[:notice] = "ログインしました！"
          else # 重複がある場合はその旨の通知
            dup_group_names = ""
            duplications.each do |dup|
              dup_group_names = "#{dup_group_names}「#{Group.find_by(id:dup).group_name}」"
            end
            flash[:notice] = "グループ#{dup_group_names}で複数のユーザーを登録しています！不要なユーザを削除してください"
          end
          # アカウントのマイページに飛ばす
          redirect_to("/account/mypage")
        end
      end
    end
  end

  def login
    # アカウント名の初期値.ログイン失敗で戻ってくる場合に入力内容を引き継ぐために使う.
    @account_name = ""
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
