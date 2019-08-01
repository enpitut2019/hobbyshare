class UserController < ApplicationController
  def select
    @users = User.all
  end

  def show
    @id = params[:select_user_id]
  end
end
