class UserController < ApplicationController
  def select
    @users = User.all
  end

  def login
    @users = User.all
  end

  def mypage
    #ユーザIDを変数に入れる
    @user_id = params[:user_id].to_i
    #セッションが存在かつ正しいユーザーの場合のみ通す
    if @session_status == "no_session" #セッションが存在しない場合
      flash[:notice] = "このページにアクセスする権限がありません"
      redirect_to("/")
      return
    else #セッションが存在しても対象のユーザーのアカウントでなければ弾く
      is_OK = false
      User.where(account_id: @session_id).each do |u|
        if u.id == @user_id
          is_OK = true
        end
      end
      if is_OK == false
        flash[:notice] = "このページにアクセスする権限がありません"
        redirect_to("/")
        return
      end
    end

    @gid = User.find(@user_id).group_id
    @group_name = Group.find(@gid).group_name
    #ユーザ名を変数に入れる
    @user_name = User.find_by(id: @user_id).name

    #ユーザの趣味を取得して変数に入れる
    @uhobby_record = UserHobby.where(user_id: @user_id)
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
    has_alias_id.each do |alias_id|
      alias_names = []
      while alias_id != nil do
        has_alias = SimilarHobby.find_by(id: alias_id)
        alias_names.push(Hobby.find_by(id: has_alias.hobby_id).hobby_name)
        alias_id = has_alias.next
      end
      @alias_names_queue.push(alias_names)
    end

    #グループおすすめ趣味の処理
    #dummyuserの情報を格納
    @dummy_user = Group.find(@gid).dummyuser
    @dummyhobby = UserHobby.where(user_id: @dummy_user)
    #dummyhobbyからhobbyIDだけを取り出して配列にする
    @dummies_id = []
    @dummyhobby.each do |record|
      @dummies_id.push(record.hobby_id)
    end
    #HobbyIDに対応するレコードを取ってくる
    @dummy_hobbies = []
    @dummies_id.each do |hid|
      @dummy_hobbies.push(Hobby.find_by(id: hid))
    end
  end

  def new_member
    #グループ内でユーザー名が被るなら弾く
    new_user_name = params[:user_name]
    group_id = params[:group_id]
    User.where(group_id: group_id).each do |u|
      if u.name == new_user_name
        flash[:notice] = "そのユーザー名は既に使用されています！"
        redirect_to("/group/#{group_id}/add_member")
        return
      end
    end

    #セッションのアカウントIDを確認して、あるかないかで分岐

    if @session_status == "no_session" #セッションがない場合
      #Accountモデルの作成
      new_account = Account.create(password: "password", is_temp: true)
      #Userモデルの作成
      new_user = User.create(name: new_user_name, group_id: group_id, account_id: new_account.id)
      #セッションのaccount_idを作成したAccountのIDにする
      session[:login_account_id] = new_account.id
      #グループメンバー一覧へリダイレクト
      redirect_to("/group/#{group_id}/list")
      flash[:notice] = "#{params[:user_name]}をグループに追加しました！"
    else
      #Userモデルからaccout_idに対応するuserを検索、見つかればgroup_idを取り出す。そのgroup_idがメンバー追加しようとしているgroup_idなら既にユーザーがあるのでメンバー一覧ページへ戻す。
      User.where(account_id: @session_id).each do |u|
        if u.group_id == group_id
          flash[:notice] = "このグループ内で既にユーザーを作成しています！"
          redirect_to("/group/#{group_id}/add_member")
          return
        end
      end

      #Userモデルの作成
      new_user = User.create(name: new_user_name, group_id: group_id, account_id: @session_id)
      flash[:notice] = "#{params[:user_name]}をグループに追加しました！"
      redirect_to("/group/#{group_id}/list")
    end
  end

  def newhobby
    #Hobbyの主キーを保存する変数hobby_idの初期化
    user_id_tmp = params[:user_id]
    hobby_id = 0
    #既に登録された趣味であった場合
    if Hobby.find_by(hobby_name: params[:hobby_name])
      hobby_id = Hobby.find_by(hobby_name: params[:hobby_name]).id
    else
      #新規にHobbyに登録する趣味の場合
      hobby_tmp = Hobby.create(hobby_name: params[:hobby_name])
      hobby_id = hobby_tmp.id
    end
    #重複するレコードがあるかどうか
    if UserHobby.find_by(hobby_id: hobby_id, user_id: user_id_tmp)
      flash[:notice] = "#{params[:hobby_name]}は既に登録されています"
    else
      #UserHobbyへの格納
      tmp = UserHobby.create(user_id: user_id_tmp, hobby_id: hobby_id)
    end
    redirect_to("/user/mypage/#{user_id_tmp}")
  end

  def account_newhobby
    #Hobbyの主キーを保存する変数hobby_idの初期化
    user_id_tmp = params[:user_id]
    hobby_id = 0
    #既に登録された趣味であった場合
    if Hobby.find_by(hobby_name: params[:hobby_name])
      hobby_id = Hobby.find_by(hobby_name: params[:hobby_name]).id
    else
      #新規にHobbyに登録する趣味の場合
      hobby_tmp = Hobby.create(hobby_name: params[:hobby_name])
      hobby_id = hobby_tmp.id
    end
    #重複するレコードがあるかどうか
    if UserHobby.find_by(hobby_id: hobby_id, user_id: user_id_tmp)
      flash[:notice] = "#{params[:hobby_name]}は既に登録されています"
    else
      #UserHobbyへの格納
      tmp = UserHobby.create(user_id: user_id_tmp, hobby_id: hobby_id)
      flash[:notice] = "#{params[:hobby_name]}を登録しました！"
    end
    redirect_to("/account/login_process")
  end

  def similar_hobby
    user_id = params[:user_id]
    hobby_id = params[:hobby_id]
    similar_hobby_name = params[:similar_hobby_name]
    user_hobby = UserHobby.find_by(user_id: user_id, hobby_id: hobby_id)

    similar_hobby_id = 0
    #既に登録された趣味であった場合
    if tmp = Hobby.find_by(hobby_name: similar_hobby_name)
      similar_hobby_id = tmp.id
    else
      #新規にHobbyに登録する趣味の場合
      similar_hobby_id = Hobby.create(hobby_name: similar_hobby_name).id
    end

    similar_hobby = SimilarHobby.create(hobby_id: similar_hobby_id)
    user_hobby.update(similar_hobbies_id: similar_hobby.id)

    flash[:notice] = "趣味の別名を登録しました！"
    redirect_to("/user/mypage/#{user_id}")

  end

  def similar_hobby_add
    user_id = params[:user_id]
    hobby_id = params[:hobby_id]
    similar_hobby_name = params[:similar_hobby_name]
    user_hobby = UserHobby.find_by(user_id: user_id, hobby_id: hobby_id)
    similar_hobby_first = SimilarHobby.find_by(id: user_hobby.similar_hobbies_id)
    similar_hobby_last = similar_hobby_first
    while similar_hobby_last.next != nil do
      similar_hobby_last = SimilarHobby.find_by(id: similar_hobby_last.next)
    end

    similar_hobby_id = 0
    #既に登録された趣味であった場合
    if tmp = Hobby.find_by(hobby_name: similar_hobby_name)
      similar_hobby_id = tmp.id
    else
      #新規にHobbyに登録する趣味の場合
      similar_hobby_id = Hobby.create(hobby_name: similar_hobby_name).id
    end

    similar_hobby = SimilarHobby.create(hobby_id: similar_hobby_id)
    similar_hobby_last.update(next: similar_hobby.id)

    flash[:notice] = "趣味の別名を追加しました！"
    redirect_to("/user/mypage/#{user_id}")

  end

  def name_change
    #userIDを受け取る
    user_id = params[:user_id]
    #userIDから対応するレコードを取り出す
    user = User.find_by(id: user_id)
    #userの名前を変更
    user.name = params[:user_name]
    #userの名前の変更を確定
    user.save
    #mypageへリダイレクト
    redirect_to("/user/mypage/#{user_id}")
  end

  def show
    @id = params[:user_id].to_i
    @gid = params[:group_id].to_i
    @group_name = Group.find(@gid).group_name

    # セッションのチェック
    if @session_status == "no_session" #セッションが存在しない場合
      flash[:notice] = "このページにアクセスする権限がありません"
      redirect_to("/")
      return
    else #セッションが存在しても対象のユーザーのアカウントでなければ弾く
      if !User.find_by(account_id: @session_id, id:@id)
        flash[:notice] = "このページにアクセスする権限がありません"
        redirect_to("/")
        return
      end
    end


    #趣味で検索するためにHobbiesの主キーであるHIDを格納する@query_hobbyidの用意
    #UIDとHIDを結びつけているUserHobbyに対して操作中ユーザのUIDで検索をかけ、そのHIDを格納。
    @query_hobbyid = UserHobby.where(user_id: @id).pluck(:hobby_id)

    #query_guser_idに同じグループに所属するユーザのUIDを格納する
    users = User.where(group_id: @gid)
    @query_guser_id = users.ids.select {|id| id != @id }
    #グループ内のユーザーの名前の配列を作成
    #user_name = User.find_by(id: @id).name
    #@group_user_all = users.pluck(:name).select {|name| name != user_name}

    @match_hobbys_name = [] #一致した趣味を順番に格納
    match_hobbys_id = [] #一致した趣味のIDを格納
    @match_users = [] #一致した趣味ごとの一致するユーザーの配列の配列

    # ログインユーザーの各趣味ごとに順番に
    @query_hobbyid.each do |qhi|
      match_gu = []
      # グループ内のユーザーごとに順番に
      @query_guser_id.each do |gui|
        # グループ内のi番目のユーザーの趣味に一致するものが存在するかチェック
        if match_hobby = UserHobby.find_by(user_id: gui, hobby_id:qhi)
          #一致した趣味が初めての一致の場合@match_hobbys_nameにpushする
          if match_hobbys_id.last != qhi
            match_hobbys_id.push(qhi)
            @match_hobbys_name.push(Hobby.find_by(id:qhi).hobby_name)
          end
          #その趣味にmatchしたユーザーを配列に追加
          match_gu.push(User.find_by(id:gui))
        end
      end
      #趣味の一致したユーザー数が0以外の場合にpush
      if !match_gu.empty?
        @match_users.push(match_gu)
      end
    end

    # 趣味の一致したユーザーの名前を重複なく配列に入れる
    @match_users_list = []
    @match_users.each do |mu|
      @match_users_list = @match_users_list | mu
    end

  end

  def match
    @user_id = params[:user_id].to_i
    @target_id = params[:target_id].to_i
    @target_name = User.find_by(id:@target_id).name
    @group_id = User.find_by(id: @user_id).group_id
    @group_name = Group.find_by(id: @group_id).group_name
    @match_hobbies = nil

    # セッションのチェック
    if @session_status == "no_session" #セッションが存在しない場合
      flash[:notice] = "このページにアクセスする権限がありません"
      redirect_to("/")
      return
    else #セッションが存在しても対象のユーザーのアカウントでなければ弾く
      if !User.find_by(account_id: @session_id, id:@user_id)
        flash[:notice] = "このページにアクセスする権限がありません"
        redirect_to("/")
        return
      end
    end

    # target_userがuserと異なるグループに所属する場合弾く
    if User.find_by(id: @target_id).group_id != @group_id
      flash[:notice] = "無効なURLです"
      redirect_to("/")
      return
    end

    # userとtarget_userの持っている趣味を全て取り出し、一致するものを得る
    user_hobbyid = UserHobby.where(user_id: @user_id).pluck(:hobby_id)
    target_hobbyid = UserHobby.where(user_id: @target_id).pluck(:hobby_id)
    match_hobbies_id = user_hobbyid & target_hobbyid
    @match_hobbies = Hobby.where(id: match_hobbies_id)

  end

  def hobby_delete
    #各種値を変数に入れる
    user_id = params[:user_id]
    hobby_id = params[:hobby_id]
    #データベースからレコードを取り出す
    hobby = Hobby.find_by(id: hobby_id)
    #Userhobbyの削除
    target = UserHobby.find_by(user_id: user_id, hobby_id: hobby_id)
    target.delete
    #趣味を削除したことを通知してマイページへリダイレクト
    flash[:notice] = "#{hobby.hobby_name}を削除しました"
    redirect_to("/user/mypage/#{user_id}")
  end


  def account_hobby_delete
    #各種値を変数に入れる
    user_id = params[:user_id]
    hobby_id = params[:hobby_id]
    account_id = params[:account_id]
    #データベースからレコードを取り出す
    hobby = Hobby.find_by(id: hobby_id)
    #Userhobbyの削除
    target = UserHobby.find_by(user_id: user_id, hobby_id: hobby_id)
    target.delete
    #趣味を削除したことを通知してマイページへリダイレクト
    flash[:notice] = "#{hobby.hobby_name}を削除しました"
    redirect_to("/account/#{params[:account_id]}")
  end

  def dummyhobby_delete
    #各種値を変数に入れる
    user_id = params[:user_id]
    hobby_id = params[:hobby_id]
    #データベースからレコードを取り出す
    hobby = Hobby.find_by(id: hobby_id)
    #Userhobbyの削除
    target = UserHobby.find_by(user_id: user_id, hobby_id: hobby_id)
    target.delete
    #趣味を削除したことを通知してマイページへリダイレクト
    flash[:notice] = "#{hobby.hobby_name}を削除しました"
    redirect_to("/group/#{params[:group_id]}/list")
  end



  def group_delete
    #各種値を変数に入れる
    user_id = params[:user_id]
    group_id = params[:group_id]
    #データベースからレコードを取り出す
    group_name = Group.find_by(id: group_id).group_name
    #Userhobbyの削除
    target = GroupBelong.find_by(user_id: user_id, group_id: group_id)
    target.delete

    if GroupBelong.where(user_id: user_id).count < 1
      UserHobby.where(user_id: user_id).delete_all
      User.find_by(id: user_id).destroy
      if GroupBelong.where(group_id: group_id).count < 1
        Group.find_by(id: group_id).destroy
        flash[:notice] = "グループとユーザーを削除しました"
        redirect_to("/")
      else
        flash[:notice] = "所属グループが0になったためユーザーを削除しました"
        redirect_to("/")
      end
    else
      #趣味を削除したことを通知してマイページへリダイレクト
      flash[:notice] = "#{group_name}を削除しました"
      redirect_to("/user/mypage/#{user_id}")
    end
  end

  def user_delete
    user_id = params[:user_id]
    user = User.find_by(id: user_id)
    group_id = user.group_id
    # ユーザーの趣味情報を削除
    UserHobby.where(user_id: user_id).delete_all
    # ユーザーの削除
    user.destroy
    flash[:notice] = "ユーザーを削除しました"
    redirect_to("/group/#{group_id}/list")
  end



  #dummyuser
  #================================================
  #DummyUser用（リダイレクト先が違うため）
  def dummy_newhobby
    #Hobbyの主キーを保存する変数hobby_idの初期化
    user_id_tmp = params[:user_id]
    hobby_id = 0
    #既に登録された趣味であった場合
    if Hobby.find_by(hobby_name: params[:hobby_name])
      hobby_id = Hobby.find_by(hobby_name: params[:hobby_name]).id
    else
      #新規にHobbyに登録する趣味の場合
      hobby_tmp = Hobby.create(hobby_name: params[:hobby_name])
      hobby_id = hobby_tmp.id
    end
    #重複するレコードがあるかどうか
    if UserHobby.find_by(hobby_id: hobby_id, user_id: user_id_tmp)
      flash[:notice] = "#{params[:hobby_name]}は既に登録されています"
    else
      #UserHobbyへの格納
      tmp = UserHobby.create(user_id: user_id_tmp, hobby_id: hobby_id)
      flash[:notice] = "#{params[:hobby_name]}を登録しました！"
    end
    redirect_to("/group/#{params[:group_id]}/list")
  end


end
