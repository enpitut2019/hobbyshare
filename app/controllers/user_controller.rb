class UserController < ApplicationController
  def select
    @users = User.all
  end

  def show
    #select.htmlで選択された人のidを@idに数字として格納
    @id = params[:select_user_id].to_i
    #主キーであるidで検索し、ユーザー（自分）の趣味等のデータを検索クエリ用に取得
    @selected_data = User.find(@id)
    #検索クエリを格納するインスタンス配列@queriesの用意
    @queries = []
    #@queriesに検索クエリとなる選択されたユーザーの趣味を格納
    @queries.push(@selected_data.hobby1).push(@selected_data.hobby2).push(@selected_data.hobby3)

    #データベースに検索をかけて趣味が共通したユーザのデータを格納する↓
    #インスタンス配列@search_resultsの用意
    @search_results = []
    #検索クエリを格納した配列の中身を用いて順に検索
    @queries.each do |q|
      #選択ユーザのidを主キーに持つデータを除外しつつ、同じ趣味をどこかに持つユーザのデータを
      #@search_resultsに格納
      @search_results.push(User.where(hobby1: q).select("name","hobby1"))
      @search_results.push(User.where(hobby2: q).select("name","hobby2"))
      @search_results.push(User.where(hobby3: q).select("name","hobby3"))
    end
    #配列内で重複したデータを削除
    #(2種類以上が共通した場合の処理を考えるとあとあと変えたほうが良いのかも)
    @search_results.uniq!

  end
end
