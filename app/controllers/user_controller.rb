class UserController < ApplicationController
  def select
    @users = User.all
  end

  def show
    #select.htmlで選択された人のidを@idに数字として格納
    #gidにグループidを格納する
    @id = 4
    @gid = 3
    #趣味で検索するためにHobbiesの主キーであるHIDを格納する@query_hobbyidの用意
    @query_hobbyid = []
    #UIDとHIDを結びつけているUserHobbyに対して操作中ユーザのUIDで検索をかけ、そのHIDを格納。
    UserHobby.where(user_id: @id).each do |h|
      @query_hobbyid.push(h.hobby_id)
    end

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

    #趣味が共通したユーザのデータを格納するインスタンス配列@results_seikeiの用意
    @results_seikei = []
    #検索対象となった同じグループのユーザに対して順に検索を行う。
    @query_guser_id.each do |gu|
      #検索対象のユーザの持つ趣味に対して順に、操作者の持つ趣味と一致しているか判定する。
      UserHobby.where(user_id: gu).each do |uh|
        @query_hobbyid.each do |qh|
          #一致していた場合、文として整形し配列@results_seikeiに格納する
          if qh == uh.hobby_id
            @results_seikei.push(Hobby.find(uh.hobby_id).hobby_name + "を" + User.find(gu).name + "さんと共有しています")
          end
        end
      end
    end
  end
end
