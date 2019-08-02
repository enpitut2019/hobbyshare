class UserController < ApplicationController
  def select
    @users = User.all
  end

  def show
    #select.htmlで選択された人のidを@idに数字として格納
    #@id = params[:select_user_id].to_i
    @id = 4
    @gid = 3
    #主キーであるidで検索し、ユーザー（自分）の趣味等のデータを検索クエリ用に取得
    @query_hobbyid = []
    UserHobby.where(user_id: @id).each do |h|
      @query_hobbyid.push(h.hobby_id)
    end

    @query_guser_id = []
    GroupBelong.where(group_id: @gid).each do |u|
      if u.user_id == @id
      else
      @query_guser_id.push(u.user_id)
      end
    end

    #データベースに検索をかけて趣味が共通したユーザのデータを格納する↓
    #インスタンス配列@results_seikeiの用意
    @results_seikei = []
    #検索クエリを格納した配列の中身を用いて順に検索
    @query_guser_id.each do |gu|
      #選択ユーザのidを主キーに持つデータを除外しつつ、同じ趣味をどこかに持つユーザのデータを
      #@results_seikeiに格納
      UserHobby.where(user_id: gu).each do |uh|
        @query_hobbyid.each do |qh|
          if qh == uh.hobby_id
            @results_seikei.push(Hobby.find(uh.hobby_id).hobby_name + "を" + User.find(gu).name + "さんと共有しています")
          end
        end
      end
    end
    #配列内で重複したデータを削除
    #(2種類以上が共通した場合の処理を考えるとあとあと変えたほうが良いのかも)

  end
end
