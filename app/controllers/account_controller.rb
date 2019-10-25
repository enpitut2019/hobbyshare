class AccountController < ApplicationController

  def sign_up
  end

  def mypage
    #現状account名は不変でUser名はいじれる感じなのでaccount名とユーザ名の表示は考えたほうがいいかも
    @account_id = params[:account_id].to_i
    #account名を格納
    @account_name = Account.find_by(id: @account_id).name
    @user_id = Account.find_by(id: @account_id).user_id
    #ここにSessionを入れる予定
    #
    #

    #よしなにポイント
    @belong_record = GroupBelong.where(user_id: @user_id)

    #accountsではグループ所属が0の場合あり
    if @belong_record.empty?

    else
      @belong = []
      @belong_record.each do |record|
        @belong.push(record.group_id)
      end
      #グループIDに対応するレコードを取ってくる
      @belong_group_name = []
      @belong.each do |gid|
        @belong_group_name.push(Group.find_by(id: gid))
      end
    end
    #ユーザ名(Model:User)を変数に格納
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

  def new_account
    new_user = User.create(name: params[:acount_name], password: "password")
    userid = new_user.id
     ac = Account.create(name: params[:acount_name], mail: params[:mail], password: params[:password], user_id: userid)
     flash[:notice] = "アカウントを作成しました！"
     redirect_to("/account/#{ac.id}")
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
    redirect_to("/account/#{ac.id}")
  end


end
