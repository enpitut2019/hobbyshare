class UserController < ApplicationController
  def select
    @users = User.all
  end

  def login
    @users = User.all
  end

  def group_login
    user_id = params[:user_id].to_i
    #パスワードの確認
    if !User.find_by(id: user_id).authenticate(params[:group_password])
      flash[:notice] = "パスワードが違います"
      redirect_to("/group/#{params[:group_id]}/list")
      return
    else
      session[:login_user_id] = user_id
    end

    #リダイレクト
    redirect_to("/user/mypage/#{params[:user_id]}")
  end

  def mypage
    #ユーザIDを変数に入れる
    @user_id = params[:user_id].to_i
    session_id = session[:login_account_id]
    #セッションが存在かつ正しいユーザーの場合のみ通す
    if session_id == nil #セッションが存在するか確認
      flash[:notice] = "このページにアクセスする権限がありません"
      redirect_to("/")
    else #セッションが存在しても対象のユーザーのアカウントでなければ弾く
      is_OK = false
      User.where(account_id: session_id).each do |u|
        if u.id == @user_id
          is_OK = true
        end
      end
      if is_OK == false
        flash[:notice] = "このページにアクセスする権限がありません"
        redirect_to("/")
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
    @uhobby_record.each do |record|
      @hobbies_id.push(record.hobby_id)
    end
    #HobbyIDに対応するレコードを取ってくる
    @users_hobbies = []
    @hobbies_id.each do |hid|
      @users_hobbies.push(Hobby.find_by(id: hid))
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
      end
    end

    #セッションのアカウントIDを確認して、あるかないかで分岐

    if session[:login_account_id] == nil #セッションがない場合
      #Accountモデルの作成
      new_account = Account.create(password: "password", is_temp: true)
      #Userモデルの作成
      new_user = User.create(name: new_user_name, group_id: group_id, password: "password", account_id: new_account.id)
      #セッションのaccount_idを作成したAccountのIDにする
      session[:login_account_id] = new_account.id
      #グループメンバー一覧へリダイレクト
      redirect_to("/group/#{group_id}/list")
      flash[:notice] = "#{params[:user_name]}をグループに追加しました！"
    else
      #Userモデルからaccout_idに対応するuserを検索、見つかればgroup_idを取り出す。そのgroup_idがメンバー追加しようとしているgroup_idなら既にユーザーがあるのでメンバー一覧ページへ戻す。
      User.where(account_id: session[:login_account_id]).each do |u|
        if u.group_id == group_id
          flash[:notice] = "このグループ内で既にユーザーを作成しています！"
          redirect_to("/group/#{group_id}/add_member")
        end
      end

      #Userモデルの作成
      new_user = User.create(name: new_user_name, group_id: group_id, password: "password", account_id: session[:login_account_id])
      flash[:notice] = "#{params[:user_name]}をグループに追加しました！"
      redirect_to("/user/#{group_id}/list")
    end
  end

  def first_setting
    @user_id = params[:user_id].to_i
    session_id = session[:login_user_id].to_i

    #セッションIDがログインユーザーと一致するか確認
    #ユーザにパスワードが設定済みか確認
    if !User.find_by(id: @user_id).authenticate("password")
      #既にログインしているか確認
      if !session_id#ログインしてないユーザがパスワード設定済みのマイページを見ようとしたら弾く
        flash[:notice] = "このページにアクセスする権限がありません"
        redirect_to("/")
      else #ログインしているユーザでも違うユーザのマイページを見ようとしたら弾く
        if @user_id != session_id
          flash[:notice] = "このページにアクセスする権限がありません"
          redirect_to("/")
        end
      end
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

  def group_password
    #userIDを受け取る
    user_id = params[:user_id]
    #userIDから対応するレコードを取り出す
    user = User.find_by(id: user_id)
    #userのpasswordを変更
    user.password = params[:group_password]
    #userの名前の変更を確定
    user.save
    flash[:notice] = "パスワードを設定しました"
    #セッションIDを設定
    session[:login_user_id] = user_id
    #mypageへリダイレクト
    redirect_to("/user/mypage/#{user_id}")
  end

  def first_password
    #userIDを受け取る
    user_id = params[:user_id]
    #userIDから対応するレコードを取り出す
    user = User.find_by(id: user_id)
    #userのpasswordを変更
    user.password = params[:group_password]
    #userの名前の変更を確定
    user.save
    #セッションIDを設定
    session[:login_user_id] = user_id
    params[:hobby_name].each do |c1, c2|
      if c2 == "1"
        hobby_id = 0
        #既に登録された趣味であった場合
        if Hobby.find_by(hobby_name: c1)
          hobby_id = Hobby.find_by(hobby_name: c1).id
        else
          #新規にHobbyに登録する趣味の場合
          hobby_tmp = Hobby.create(hobby_name: c1)
          hobby_id = hobby_tmp.id
        end
        #重複するレコードがあるかどうか
        if UserHobby.find_by(hobby_id: hobby_id, user_id: user_id)
        else
          #UserHobbyへの格納
          tmp = UserHobby.create(user_id: user_id, hobby_id: hobby_id)
        end
      end
    end
    #mypageへリダイレクト
    redirect_to("/user/mypage/#{user_id}")
  end

  def show
    #select.htmlで選択された人のidを@idに数字として格納
    #gidにグループidを格納する
    @id = params[:user_id].to_i
    @gid = params[:group_id].to_i
    #趣味で検索するためにHobbiesの主キーであるHIDを格納する@query_hobbyidの用意
    @query_hobbyid = []
    #UIDとHIDを結びつけているUserHobbyに対して操作中ユーザのUIDで検索をかけ、そのHIDを格納。
    UserHobby.where(user_id: @id).each do |h|
      @query_hobbyid.push(h.hobby_id)
    end

    #query_guser_idに同じグループに所属するユーザのUIDを格納する
    @query_guser_id = []
    @query_guser_id_andme = []
    #GIDとUIDを結びつけているGroupBelongに対して選択されたグループのGIDで検索をかけ、
    #そのグループに所属する操作者を除くユーザのUIDを格納する。
    GroupBelong.where(group_id: @gid).each do |u|
      if u.user_id == @id
        @query_guser_id_andme.push(u.user_id)
      else
        @query_guser_id.push(u.user_id)
        @query_guser_id_andme.push(u.user_id)
      end
    end
    @group_user_all = []
    @query_guser_id.each do |qgi|
      @group_user_all.push(User.find(qgi).name)
    end

    @group_user_all_andme = []
    @query_guser_id_andme.each do |qgi|
      @group_user_all_andme.push(User.find(qgi).name)
    end

    #趣味が共通したユーザのデータを格納するインスタンス配列@results_seikeiの用意
    @results_seikei = []
    #検索対象となった同じグループのユーザに対して順に検索を行う。
    @query_guser_id.each do |gu|
      #検索対象のユーザの持つ趣味に対して順に、操作者の持つ趣味と一致しているか判定する。
      UserHobby.where(user_id: gu).each do |uh|
        @query_hobbyid.each do |qh|
          #一致していた場合、文として整形し配列@results_seikeiに格納する
          if qh == uh.hobby_id
            @results_seikei.push(Hobby.find(uh.hobby_id).hobby_name + "を" + User.find(gu).name + "さんと,")
          end
        end
      end
    end
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

 #もう使わないはず
#  def group_delete
    #各種値を変数に入れる
  #  user_id = params[:user_id]
  #  group_id = params[:group_id]
    #データベースからレコードを取り出す
  #  group_name = Group.find_by(id: group_id).group_name
    #Userhobbyの削除
  #  target = GroupBelong.find_by(user_id: user_id, group_id: group_id)
  #  target.delete

  #  if GroupBelong.where(user_id: user_id).count < 1
  #    UserHobby.where(user_id: user_id).delete_all
  #    User.find_by(id: user_id).destroy
  #    if GroupBelong.where(group_id: group_id).count < 1
  #      Group.find_by(id: group_id).destroy
  #      flash[:notice] = "グループとユーザーを削除しました"
  #      redirect_to("/")
  #    else
  #      flash[:notice] = "所属グループが0になったためユーザーを削除しました"
  #      redirect_to("/")
  #    end
  #  else
  #    #趣味を削除したことを通知してマイページへリダイレクト
  #    flash[:notice] = "#{group_name}を削除しました"
  #    redirect_to("/user/mypage/#{user_id}")
  #  end
  #end



end
