class GroupController < ApplicationController
  def list
    #select.htmlで選択された人のidを@idに数字として格納
    #gidにグループidを格納する
    @id = params[:user_id].to_i
    @gid = params[:group_id].to_i

    #query_guser_idに同じグループに所属するユーザのUIDを格納する
    @query_guser_id = []
    #GIDとUIDを結びつけているGroupBelongに対して選択されたグループのGIDで検索をかけ、
    #そのグループに所属する操作者を除くユーザのUIDを格納する。
    GroupBelong.where(group_id: @gid).each do |u|
      if u.user_id == @id
      else
      @query_guser_id.push(u.user_id)
      end
    end
    @group_user_all = []
    @query_guser_id.each do |qgi|
      @group_user_all.push(User.find(qgi).name)
    end

  end
end
