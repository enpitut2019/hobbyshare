class GroupController < ApplicationController
  def top
  end

  def search
    if Group.find_by(group_name: params[:group_name])
      @gid = Group.find_by(group_name: params[:group_name]).id#入力されたグループのメンバー一覧ページへの飛ばす
      redirect_to("/group/#{@gid}/list") #入力されたグループのページへリダイレクト
    else
      flash.now[:notice] = "入力された名前のグループは存在しません"#存在しないグループ名が入力された場合はやり直させる
      render("top")
    end
  end

  def list
    #gidにグループidを格納する
    @gid = params[:group_id].to_i
    #query_guser_idにグループに所属するユーザのUIDを格納する
    @query_guser = []
    #Userにて指定グループのgidを持つユーザを抽出
    User.where(group_id: @gid).each do |u|
      @query_guser.push(u)
    end
  end

  def make
  end

  def new
    #既に同じ名前のグループが存在する場合にはやり直させる
    if Group.find_by(group_name: params[:group_name])
      flash[:notice] = "そのグループ名は既に使用されています"
      render("make")
      return
    end

    #グループを新規作成
    new_group = Group.new(group_name: params[:group_name])
    new_group.save

    #グループメンバーの数だけ仮ユーザーを作成
    number_of_menber = params[:number_of_menber].to_i
    group_name = "#{params[:group_name]}_"
    for i in 1..number_of_menber do
      #menber_name = group_name + i.to_s
      user = User.new(name: params[:user_name])
      user.password = "password"
      user.save
      gb = GroupBelong.new(group_id: new_group.id, user_id: user.id)
      gb.save
    end

    redirect_to("/user/first_setting/#{user.id}") #グループ内メンバー一覧ページへリダイレクト
  end

  def add_member
    @group_id = params[:group_id].to_i
  end

end
