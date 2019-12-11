class GroupController < ApplicationController
  def top
  end

  def enter
    #グループ名の初期値.グループ作成失敗で戻ってくる場合に入力内容を引き継ぐために使う.
    @group_name = ""
    @login_group_names = nil
    if @session_status == "no_session"
      #ログインしているグループはない
    elsif @session_status == "temporary_account"
      @login_group_ids = User.where(account_id: @session_id).pluck(:group_id)
      @login_group_names = Group.where(id: @login_group_ids).pluck(:group_name)
    else
      @login_group_ids = User.where(account_id: @session_id).pluck(:group_id)
      @login_group_names = Group.where(id: @login_group_ids).pluck(:group_name)
    end
  end

  def search
    if @gtoken = Group.find_by(group_name: params[:group_name])&.token
      #入力されたグループが存在するならばメンバー一覧ページへ飛ばす
      redirect_to("/group/list/#{@gtoken}")
    else
      #存在しないグループ名が入力された場合はやり直させる
      flash.now[:notice] = "入力された名前のグループは存在しません"
      @group_name = params[:group_name] #入力内容の引継ぎ
      render("enter")
    end
  end

  def list
    #gidにグループidを格納する
    @group_token = params[:group_token]
    @gid = Group.find_by(token: @group_token)&.id
    if @gid == nil
      render plain: "404エラー\nお探しのページは存在しません", status: 404
      return
    end
    #dummyuserの情報を格納
    @group_name = Group.find(@gid).group_name
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

    #query_guser_idにグループに所属するユーザのUIDを格納する
    @query_guser = []
    #Userにて指定グループのgidを持つユーザを抽出
    @login_uid == nil
    User.where(group_id: @gid).each do |u|
      @query_guser.push(u)
    end
    if @session_status != "no_session"
      account_user = User.where(account_id: @session_id)&.find_by(group_id: @gid)
      @login_uid = account_user&.id
      @login_uname = account_user&.name
    end
  end

  def make
    #グループ名の初期値.グループ作成失敗で戻ってくる場合に入力内容を引き継ぐために使う.
    @group_name = ""
    @login_group_names = nil
    if @session_status == "no_session"
      #ログインしているグループはない
    elsif @session_status == "temporary_account"
      @login_group_ids = User.where(account_id: @session_id).pluck(:group_id)
      @login_group_names = Group.where(id: @login_group_ids).pluck(:group_name)
    else
      @login_group_ids = User.where(account_id: @session_id).pluck(:group_id)
      @login_group_names = Group.where(id: @login_group_ids).pluck(:group_name)
    end
  end

  def new
    #既に同じ名前のグループが存在する場合にはやり直させる
    if Group.find_by(group_name: params[:group_name])
      flash[:notice] = "そのグループ名は既に使用されています"
      @group_name = params[:group_name] #グループ名の入力内容を#入力内容の引継ぎ
      render("make")
      return
    end

    #グループを新規作成
    dummy = User.create(token:SecureRandom.urlsafe_base64, opentoken:SecureRandom.urlsafe_base64)
    new_group = Group.create(group_name: params[:group_name], dummyuser: dummy.id, token:SecureRandom.urlsafe_base64)

    redirect_to("/group/list/#{new_group.token}") #グループ内メンバー一覧ページへリダイレクト
  end

  def add_member
    @group_id = Group.find_by(token: params[:group_token])&.id
    if @group_id == nil
      render plain: "404エラー\nお探しのページは存在しません", status: 404
      return
    end
  end



end
