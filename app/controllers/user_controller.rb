class UserController < ApplicationController
  def select
    @users = User.all
  end

  def show
  end
end
