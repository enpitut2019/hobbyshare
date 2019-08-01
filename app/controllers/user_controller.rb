class UserController < ApplicationController
  def select
    @users = User.all
  end
end
