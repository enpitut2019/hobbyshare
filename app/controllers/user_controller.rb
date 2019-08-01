class UserController < ApplicationController
  def select
    @users = User.all
  end

  def show
    #select.htmlで選択された人のidを@idに数字として格納
    @id = params[:select_user_id].to_i
  end
end
