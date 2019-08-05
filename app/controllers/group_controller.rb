class GroupController < ApplicationController
  def top

  end
  def list
    #select.htmlで選択された人のidを@idに数字として格納
    #gidにグループidを格納する
    @id = params[:user_id].to_i
    @gid = params[:group_id].to_i

    #query_guser_idに同じグループに所属するユーザのUIDを格納する
    @query_guser = []
    #GIDとUIDを結びつけているGroupBelongに対して選択されたグループのGIDで検索をかけ、
    GroupBelong.where(group_id: @gid).each do |u|
      @query_guser.push(u.user_id)
    end
    #group_user_allにUserから取り出したレコードを格納する
    @group_user_all = []
    @query_guser.each do |qg|
      @group_user_all.push(User.find(qg))
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
      menber_name = group_name + i.to_s
      user = User.new(name:menber_name)
      user.save
      gb = GroupBelong.new(group_id: new_group.id, user_id: user.id)
      gb.save
    end

    redirect_to("/group/#{new_group.id}/list") #グループ内メンバー一覧ページへリダイレクト
  end

end
