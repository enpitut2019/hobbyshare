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
    @group_name = ""
  end

  def new
    #既に同じ名前のグループが存在する場合にはやり直させる
    if Group.find_by(group_name: params[:group_name])
      flash[:notice] = "そのグループ名は既に使用されています"
      @group_name = params[:group_name] #グループ名の入力内容を保存
      render("make")
      return
    end

    #グループを新規作成
    new_group = Group.create(group_name: params[:group_name])

    redirect_to("/group/#{new_group.id}/list") #グループ内メンバー一覧ページへリダイレクト
  end

end
