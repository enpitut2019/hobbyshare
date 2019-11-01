class GroupController < ApplicationController
  def top
  end

  def enter
    #グループ名の初期値.ログイン失敗で戻ってくる場合に入力内容を引き継ぐために使う.
    @group_name = ""
  end

  def search
    if @gid = Group.find_by(group_name: params[:group_name])&.id
      #入力されたグループが存在するならばメンバー一覧ページへ飛ばす
      redirect_to("/group/#{@gid}/list")
    else
      #存在しないグループ名が入力された場合はやり直させる
      flash.now[:notice] = "入力された名前のグループは存在しません"
      @group_name = params[:group_name] #入力内容の引継ぎ
      render("enter")
    end
  end

  def list
    #gidにグループidを格納する
    @gid = params[:group_id].to_i
    #query_guser_idにグループに所属するユーザのUIDを格納する
    @query_guser = []
    #Userにて指定グループのgidを持つユーザを抽出
    @login_uid == nil
    User.where(group_id: @gid).each do |u|
      @query_guser.push(u)
    end
    if session[:login_account_id] != nil
      User.where(account_id: session[:login_account_id]).each do |u|
        if u.group_id == @gid
          @login_uid = u.id
          @login_uname = u.name
        end
      end
    end
  end

  def make
    #グループ名の初期値.グループ作成失敗で戻ってくる場合に入力内容を引き継ぐために使う.
    @group_name = ""
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
    new_group = Group.create(group_name: params[:group_name])

    redirect_to("/group/#{new_group.id}/list") #グループ内メンバー一覧ページへリダイレクト
  end

  def add_member
    @group_id = params[:group_id].to_i
  end



end
