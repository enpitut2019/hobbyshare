class UserController < ApplicationController

  def mypage
    user = User.find_by(token: params[:user_token])
    if user == nil
      render plain: "404エラー\nお探しのページは存在しません", status: 404
      return
    end
    #ユーザIDを変数に入れる
    @user_id = user.id
    @user_token = user.token
    @user_name = user.name
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

    @gid = user.group_id
    group = Group.find(@gid)
    @group_name = group.group_name
    @group_token = group.token
    #ユーザ名を変数に入れる
    @user_name = user.name

    #ユーザの趣味を取得して変数に入れる
    @uhobby_record = UserHobby.where(user_id: @user_id).order(:id)
    #uhobby_recordからhobbyIDだけを取り出して配列にする
    @hobbies_id = []
    @hobbies_option = []
    @has_alias = []
    has_alias_id = [] #別名を持つ趣味
    @uhobby_record.each do |record|
      @hobbies_id.push(record.hobby_id)
      @hobbies_option.push(record.open)
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

    @user_intro = User.find_by(id: @user_id).intro

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

    #グループメンバーの公開趣味を取ってくる
    @group_users = User.where(group_id: @gid)
    group_users_id = @group_users.pluck(:id)
    group_open_userhobbies = UserHobby.where(user_id: group_users_id, open:true)
    group_open_hobbies_id = group_open_userhobbies.pluck(:hobby_id)
    @group_open_hobbies = Hobby.where(id: group_open_hobbies_id)
  end

  def new_member
    group_token = params[:group_token]
    group = Group.find_by(token: group_token)
    if group == nil
      render plain: "500エラー\nデータの整合が取れません", status: 500
      return
    end
    group_id = group.id
    new_user_name = params[:user_name]

    #グループ内でユーザー名が被るなら弾く
    User.where(group_id: group_id).each do |u|
      if u.name == new_user_name
        flash[:notice] = "そのユーザー名は既に使用されています！"
        redirect_to("/group/add_member/#{group_token}")
        return
      end
    end

    #セッションのアカウントIDを確認して、あるかないかで分岐

    if @session_status == "no_session" #セッションがない場合
      #Accountモデルの作成
      new_account = Account.create(password: "password", is_temp: true)
      #Userモデルの作成
      new_user = User.create(name: new_user_name, group_id: group_id, account_id: new_account.id, token:SecureRandom.urlsafe_base64, opentoken:SecureRandom.urlsafe_base64)
      #セッションのaccount_idを作成したAccountのIDにする
      session[:login_account_id] = new_account.id
      #グループメンバー一覧へリダイレクト
      redirect_to("/group/list/#{group_token}")
      flash[:notice] = "#{params[:user_name]}をグループに追加しました！"
    else
      #Userモデルからaccout_idに対応するuserを検索、見つかればgroup_idを取り出す。そのgroup_idがメンバー追加しようとしているgroup_idなら既にユーザーがあるのでメンバー一覧ページへ戻す。
      User.where(account_id: @session_id).each do |u|
        if u.group_id == group_id
          flash[:notice] = "このグループ内で既にユーザーを作成しています！"
          redirect_to("/group/add_member/#{group_token}")
          return
        end
      end

      #Userモデルの作成
      new_user = User.create(name: new_user_name, group_id: group_id, account_id: @session_id, token:SecureRandom.urlsafe_base64, opentoken:SecureRandom.urlsafe_base64)
      flash[:notice] = "#{params[:user_name]}をグループに追加しました！"
      redirect_to("/group/list/#{group_token}")
    end
  end

  def newhobby
    user_token = params[:user_token]
    user = User.find_by(token: user_token)
    if user == nil
      render plain: "500エラー\nデータの整合が取れません", status: 500
      return
    end
    user_id_tmp = user.id
    if params[:open_option] == "open"
      open_option = true
    else
      open_option = false
    end

    hobby_id = 0
    registered_hobby = []
    #既に登録された趣味であった場合
    hobbyname = params[:hobby_name].split(",")
    hobbyname.each do |name|
      if name == ""
      else
        if Hobby.find_by(hobby_name: name)
          hobby_id = Hobby.find_by(hobby_name: name).id
        else
          #新規にHobbyに登録する趣味の場合
          hobby_tmp = Hobby.create(hobby_name: name)
          hobby_id = hobby_tmp.id
        end
        #重複するレコードがあるかどうか
        if UserHobby.find_by(hobby_id: hobby_id, user_id: user_id_tmp)
          registered_hobby.push(name)
        else
          #UserHobbyへの格納
          UserHobby.create(user_id: user_id_tmp, hobby_id: hobby_id, open: open_option)
        end
      end
    end
    if registered_hobby.empty?
    else
      rh_names = ""
      count = 1
      registered_hobby.each do |rh|
        if count == 1
          rh_names = rh
          count += 1
        else
          rh_names = rh_names + ',' + rh
        end
      end
        flash[:notice] = "#{rh_names}は既に登録されています"
    end
    redirect_to("/user/mypage/#{user_token}")
  end


  def ac_newhobbies
    user_token = params[:user_token]
    user = User.find_by(token: user_token)
    if user == nil
      render plain: "500エラー\nデータの整合が取れません", status: 500
      return
    end
    user_id_tmp = user.id
    user_name = user.name
    group_name = params[:group_name]

    @dummy_user_id = @login_account.user_id
    #ユーザの趣味を取得して変数に入れる
    @uhobby_record = UserHobby.where(user_id: @dummy_user_id)

    @uhobby_record.each do |record|
      #重複するレコードがあるかどうか
      if UserHobby.find_by(user_id: user_id_tmp, hobby_id: record.hobby_id)
        # 重複したら何もしない
      else
          #UserHobbyへの格納
          new_hobby = UserHobby.create(user_id: user_id_tmp, hobby_id: record.hobby_id, open: record.open)
          if record.similar_hobbies_id != nil
            target = new_hobby
            target_is_user_hobby = true
            next_shid = record.similar_hobbies_id
            while next_shid != nil
              sh = SimilarHobby.find_by(id: next_shid)
              tmp = SimilarHobby.create(user_id: user_id_tmp, hobby_id: sh.hobby_id)
              if target_is_user_hobby
                target.similar_hobbies_id = tmp.id
              else
                target.next = tmp.id
              end
              target.save
              next_shid = sh.next
              target = tmp
              target_is_user_hobby = false
            end
          end
      end
    end
    flash[:notice] = "#{group_name}:#{user_name}に趣味一覧を登録しました！"
    redirect_to("/account/mypage")
  end

  def account_newhobby
    user_token = params[:user_token]
    user = User.find_by(token: user_token)
    if user == nil
      render plain: "500エラー\nデータの整合が取れません", status: 500
      return
    end
    user_id_tmp = user.id

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
    redirect_to("/account/mypage")
  end

  def userintro
    user_token = params[:user_token]
    user = User.find_by(token: user_token)
    if user == nil
      render plain: "500エラー\nデータの整合が取れません", status: 500
      return
    end

    user.intro = params[:user_intro]
    user.save
    redirect_to("/user/mypage/#{user_token}")
  end

  def similar_hobby
    user_token = params[:user_token]
    user = User.find_by(token: user_token)
    if user == nil
      render plain: "500エラー\nデータの整合が取れません", status: 500
      return
    end
    user_id = user.id
    hobby_id = params[:hobby_id].to_i
    similar_hobby_name = params[:similar_hobby_name]
    user_hobby = UserHobby.find_by(user_id: user_id, hobby_id: hobby_id)
    if user_hobby == nil
      render plain: "500エラー\nデータの整合が取れません", status: 500
      return
    end

    similar_hobby_id = 0
    #既に登録された趣味であった場合
    if tmp = Hobby.find_by(hobby_name: similar_hobby_name)
      similar_hobby_id = tmp.id
    else
      #新規にHobbyに登録する趣味の場合
      similar_hobby_id = Hobby.create(hobby_name: similar_hobby_name).id
    end

    #重複するレコードがあったら登録しない
    if UserHobby.find_by(hobby_id: similar_hobby_id, user_id: user_id) || SimilarHobby.find_by(hobby_id: similar_hobby_id, user_id: user_id)
      flash[:notice] = "#{similar_hobby_name}は既に登録されています"
      redirect_to("/user/mypage/#{user_token}")
      return
    end

    sh = SimilarHobby.create(hobby_id: similar_hobby_id, user_id: user_id)
    user_hobby.update(similar_hobbies_id: sh.id)

    flash[:notice] = "趣味の別名を登録しました！"
    redirect_to("/user/mypage/#{user_token}")

  end

  def ac_similar_hobby
    user_token = params[:user_token]
    user = User.find_by(token: user_token)
    if user == nil
      render plain: "500エラー\nデータの整合が取れません", status: 500
      return
    end
    user_id = user.id
    hobby_id = params[:hobby_id].to_i
    similar_hobby_name = params[:similar_hobby_name]
    user_hobby = UserHobby.find_by(user_id: user_id, hobby_id: hobby_id)
    if user_hobby == nil
      render plain: "500エラー\nデータの整合が取れません", status: 500
      return
    end

    similar_hobby_id = 0
    #既に登録された趣味であった場合
    if tmp = Hobby.find_by(hobby_name: similar_hobby_name)
      similar_hobby_id = tmp.id
    else
      #新規にHobbyに登録する趣味の場合
      similar_hobby_id = Hobby.create(hobby_name: similar_hobby_name).id
    end

    #重複するレコードがあったら登録しない
    if UserHobby.find_by(hobby_id: similar_hobby_id, user_id: user_id) || SimilarHobby.find_by(hobby_id: similar_hobby_id, user_id: user_id)
      flash[:notice] = "#{similar_hobby_name}は既に登録されています"
      redirect_to("/account/mypage")
      return
    end

    sh = SimilarHobby.create(hobby_id: similar_hobby_id, user_id: user_id)
    user_hobby.update(similar_hobbies_id: sh.id)

    flash[:notice] = "趣味の別名を登録しました！"
    redirect_to("/account/mypage")

  end

  def similar_hobby_add
    user_token = params[:user_token]
    user = User.find_by(token: user_token)
    if user == nil
      render plain: "500エラー\nデータの整合が取れません", status: 500
      return
    end
    user_id = user.id
    hobby_id = params[:hobby_id].to_i
    similar_hobby_name = params[:similar_hobby_name]

    user_hobby = UserHobby.find_by(user_id: user_id, hobby_id: hobby_id)
    if user_hobby == nil
      render plain: "500エラー\nデータの整合が取れません", status: 500
      return
    end
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

    #重複するレコードがあったら登録しない
    if UserHobby.find_by(hobby_id: similar_hobby_id, user_id: user_id) || SimilarHobby.find_by(hobby_id: similar_hobby_id, user_id: user_id)
      flash[:notice] = "#{similar_hobby_name}は既に登録されています"
      redirect_to("/user/mypage/#{user_token}")
      return
    end

    similar_hobby = SimilarHobby.create(hobby_id: similar_hobby_id, user_id: user_id)
    similar_hobby_last.update(next: similar_hobby.id)

    flash[:notice] = "趣味の別名を追加しました！"
    redirect_to("/user/mypage/#{user_token}")

  end


  def hobby_open
    user_token = params[:user_token]
    user = User.find_by(token: user_token)
    if user == nil
      render plain: "500エラー\nデータの整合が取れません", status: 500
      return
    end
    user_id = user.id
    hobby_id = params[:hobby_id].to_i
    if params[:options] == "open"
      do_open = true
    else
      do_open = false
    end
    user_hobby = UserHobby.find_by(user_id: user_id, hobby_id: hobby_id)
    if user_hobby == nil
      render plain: "500エラー\nデータの整合が取れません", status: 500
      return
    end

    if do_open
      user_hobby.update(open: true)
      flash[:notice] = "趣味の公開オプションを公開に設定しました！"
    else
      user_hobby.update(open: false)
      flash[:notice] = "趣味の公開オプションを非公開に設定しました！"
    end
    redirect_to("/user/mypage/#{user_token}")
  end


  def ac_similar_hobby_add
    user_token = params[:user_token]
    user = User.find_by(token: user_token)
    if user == nil
      render plain: "500エラー\nデータの整合が取れません", status: 500
      return
    end
    user_id = user.id
    hobby_id = params[:hobby_id].to_i
    similar_hobby_name = params[:similar_hobby_name]

    user_hobby = UserHobby.find_by(user_id: user_id, hobby_id: hobby_id)
    if user_hobby == nil
      render plain: "500エラー\nデータの整合が取れません", status: 500
      return
    end
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

    #重複するレコードがあったら登録しない
    if UserHobby.find_by(hobby_id: similar_hobby_id, user_id: user_id) || SimilarHobby.find_by(hobby_id: similar_hobby_id, user_id: user_id)
      flash[:notice] = "#{similar_hobby_name}は既に登録されています"
      redirect_to("/account/mypage")
      return
    end

    similar_hobby = SimilarHobby.create(hobby_id: similar_hobby_id, user_id: user_id)
    similar_hobby_last.update(next: similar_hobby.id)

    flash[:notice] = "趣味の別名を追加しました！"
    redirect_to("/account/mypage")
  end

  def name_change
    user_token = params[:user_token]
    user = User.find_by(token: user_token)
    if user == nil
      render plain: "500エラー\nデータの整合が取れません", status: 500
      return
    end

    #userの名前を変更
    user.name = params[:user_name]
    user.save
    #mypageへリダイレクト
    flash[:notice] = "名前を変更しました！"
    redirect_to("/user/mypage/#{user_token}")
  end

  def show
    user = User.find_by(token: params[:user_token])
    if user == nil
      render plain: "404エラー\nお探しのページは存在しません", status: 404
      return
    end

    @id = user.id
    @user_token = user.token
    group = Group.find_by(id: user.group_id)
    @gid = group.id
    @group_name = group.group_name
    @group_token = group.token

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


    #趣味で検索するためにHobbiesの主キーであるHIDを格納するquery_hobbyidの用意
    #UIDとHIDを結びつけているUserHobbyに対して操作中ユーザのUIDで検索をかけ、そのHIDを格納。
    user_hobbys = UserHobby.where(user_id: @id)
    query_hobbyid = user_hobbys.pluck(:hobby_id)
    query_has_similar = user_hobbys.pluck(:similar_hobbies_id)

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
    query_hobbyid.each_with_index do |qhi,index|
      match_gu = []
      # グループ内のユーザーごとに順番に
      @query_guser_id.each do |gui|
        is_match = false
        # グループ内のi番目のユーザーの趣味に一致するものが存在するかチェック
        if UserHobby.find_by(user_id:gui, hobby_id:qhi) || SimilarHobby.find_by(user_id:gui,hobby_id:qhi)
          is_match = true
        end
        # 同名趣味がある場合さらに検索
        if query_has_similar[index] && !is_match
          similar_hobby_id = query_has_similar[index]
          while similar_hobby_id != nil do
            sh = SimilarHobby.find_by(id: similar_hobby_id)
            hid = sh.hobby_id
            if UserHobby.find_by(user_id:gui, hobby_id:hid) || SimilarHobby.find_by(user_id:gui,hobby_id:hid)
              is_match = true
              break
            else
              similar_hobby_id = sh.next
            end
          end
        end
        # 趣味が一致した場合
        if is_match
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
    @user_token = params[:user_token]
    target_user_open_token = params[:target_token]
    user = User.find_by(token: @user_token)
    target_user = User.find_by(opentoken: target_user_open_token)
    if (user == nil || target_user == nil)
      render plain: "404エラー\nお探しのページは存在しません", status: 404
      return
    end

    @user_id = user.id
    @target_id = target_user.id
    @target_name = target_user.name
    @group_id = user.group_id
    group = Group.find_by(id: @group_id)
    @group_name = group.group_name
    @group_token = group.token
    @target_intro = target_user.intro

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

    @match_hobbies = nil
    # matchしたhobbyのID
    match_hobbies_id = []
    # targetのhobbyIDの配列
    target_hobbyid = UserHobby.where(user_id: @target_id).pluck(:hobby_id) | SimilarHobby.where(user_id: @target_id).pluck(:hobby_id)
    # userのそれぞれの趣味が一致するか調べる
    user_hobbyid = UserHobby.where(user_id: @user_id)
    user_hobbyid.each do |ushb|
      is_match = false
      if target_hobbyid.include?(ushb.hobby_id)
        is_match = true
      elsif (slhb_id = ushb.similar_hobbies_id) != nil #趣味の別名が存在する場合
        while slhb_id != nil do
          slhb = SimilarHobby.find_by(id: slhb_id)
          if target_hobbyid.include?(slhb.hobby_id)
            is_match = true
            break
          end
          slhb_id = slhb.next
        end
      end
      # 趣味が一致していたらmatch_hobbies_idに格納
      if is_match
        match_hobbies_id.push(ushb.hobby_id)
      end
    end
    # matchした趣味を取り出す
    @match_hobbies = Hobby.where(id: match_hobbies_id)


  end

  def hobby_delete
    user_token = params[:user_token]
    user = User.find_by(token: user_token)
    if user == nil
      render plain: "500エラー\nデータの整合が取れません", status: 500
      return
    end
    user_id = user.id
    hobby_id = params[:hobby_id].to_i

    #データベースからレコードを取り出す
    hobby = Hobby.find_by(id: hobby_id)
    #Userhobbyの削除
    target = UserHobby.find_by(user_id: user_id, hobby_id: hobby_id)
    if target == nil
      render plain: "500エラー\nデータの整合が取れません", status: 500
      return
    end
    target_similar_hobby_id = target.similar_hobbies_id
    target.delete
    #趣味の別名があった場合それも全て削除
    while target_similar_hobby_id != nil
      target_similar_hobby = SimilarHobby.find_by(id: target_similar_hobby_id)
      target_similar_hobby_id = target_similar_hobby.next
      target_similar_hobby.destroy
    end
    #趣味を削除したことを通知してマイページへリダイレクト
    flash[:notice] = "#{hobby.hobby_name}を削除しました"
    redirect_to("/user/mypage/#{user_token}")
  end

  def similar_hobby_delete
    user_token = params[:user_token]
    user = User.find_by(token: user_token)
    if user == nil
      render plain: "500エラー\nデータの整合が取れません", status: 500
      return
    end
    user_id = user.id
    similar_hobby_id = params[:similar_hobby_id].to_i

    #データベースからレコードを取り出す
    similar_hobby = SimilarHobby.find_by(id: similar_hobby_id)
    if similar_hobby == nil
      render plain: "500エラー\nデータの整合が取れません", status: 500
      return
    end
    similar_hobby_name = Hobby.find_by(id: similar_hobby.hobby_id).hobby_name

    if uh = UserHobby.find_by(similar_hobbies_id: similar_hobby.id)
      uh.update(similar_hobbies_id: similar_hobby.next)
    elsif sh = SimilarHobby.find_by(next: similar_hobby.id)
      sh.update(next: similar_hobby.next)
    else
      flash[:notice] = "エラーが起きました"
      redirect_to("/user/mypage/#{user_token}")
      return
    end

    similar_hobby.destroy

    #趣味を削除したことを通知してマイページへリダイレクト
    flash[:notice] = "#{similar_hobby_name}を削除しました"
    redirect_to("/user/mypage/#{user_token}")
  end

  def ac_similar_hobby_delete
    user_token = params[:user_token]
    user = User.find_by(token: user_token)
    if user == nil
      render plain: "500エラー\nデータの整合が取れません", status: 500
      return
    end
    user_id = user.id
    similar_hobby_id = params[:similar_hobby_id].to_i

    #データベースからレコードを取り出す
    similar_hobby = SimilarHobby.find_by(id: similar_hobby_id, user_id: user_id)
    if similar_hobby == nil
      render plain: "500エラー\nデータの整合が取れません", status: 500
      return
    end
    similar_hobby_name = Hobby.find_by(id: similar_hobby.hobby_id).hobby_name

    if uh = UserHobby.find_by(similar_hobbies_id: similar_hobby.id)
      uh.update(similar_hobbies_id: similar_hobby.next)
    elsif sh = SimilarHobby.find_by(next: similar_hobby.id)
      sh.update(next: similar_hobby.next)
    else
      flash[:notice] = "エラーが起きました"
      redirect_to("/account/mypage")
      return
    end

    similar_hobby.destroy

    #趣味を削除したことを通知してマイページへリダイレクト
    flash[:notice] = "#{similar_hobby_name}を削除しました"
    redirect_to("/account/mypage")
  end

  def account_hobby_delete
    user_token = params[:user_token]
    user = User.find_by(token: user_token)
    if user == nil
      render plain: "500エラー\nデータの整合が取れません", status: 500
      return
    end
    user_id = user.id
    hobby_id = params[:hobby_id].to_i

    #データベースからレコードを取り出す
    hobby = Hobby.find_by(id: hobby_id)
    #Userhobbyの削除
    target = UserHobby.find_by(user_id: user_id, hobby_id: hobby_id)
    if target == nil
      render plain: "500エラー\nデータの整合が取れません", status: 500
      return
    end
    target_similar_hobby_id = target.similar_hobbies_id
    target.delete
    #趣味の別名があった場合それも全て削除
    while target_similar_hobby_id != nil
      target_similar_hobby = SimilarHobby.find_by(id: target_similar_hobby_id)
      target_similar_hobby_id = target_similar_hobby.next
      target_similar_hobby.destroy
    end

    #趣味を削除したことを通知してマイページへリダイレクト
    flash[:notice] = "#{hobby.hobby_name}を削除しました"
    redirect_to("/account/mypage")
  end

  def dummyhobby_delete
    #各種値を変数に入れる
    group_token = Group.find_by(id: params[:group_id].to_i)&.token
    user_id = params[:user_id]
    hobby_id = params[:hobby_id]
    if group_token == nil
      render plain: "500エラー\nデータの整合が取れません", status: 500
      return
    end
    #データベースからレコードを取り出す
    hobby = Hobby.find_by(id: hobby_id)
    #Userhobbyの削除
    target = UserHobby.find_by(user_id: user_id, hobby_id: hobby_id)
    target.delete
    #趣味を削除したことを通知してマイページへリダイレクト
    flash[:notice] = "#{hobby.hobby_name}を削除しました"
    redirect_to("/group/list/#{group_token}")
  end

  def user_delete
    user_token = params[:user_token]
    user = User.find_by(token: user_token)
    if user == nil
      render plain: "500エラー\nデータの整合が取れません", status: 500
      return
    end
    user_id = user.id
    group_token = Group.find_by(id: user.group_id).token
    # ユーザーの趣味情報を削除
    UserHobby.where(user_id: user_id).delete_all
    SimilarHobby.where(user_id: user_id).delete_all
    # ユーザーの削除
    user.destroy
    flash[:notice] = "ユーザーを削除しました"
    redirect_to("/group/list/#{group_token}")
  end



  #dummyuser
  #================================================
  #DummyUser用（リダイレクト先が違うため）
  def dummy_newhobby
    group_token = Group.find_by(id: params[:group_id].to_i).token
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
    redirect_to("/group/list/#{group_token}")
  end


end
