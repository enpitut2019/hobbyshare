class GroupController < ApplicationController
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
    @group_user_all = []
    @query_guser.each do |qg|
      @group_user_all.push(User.find(qg))
    end

  end
end
