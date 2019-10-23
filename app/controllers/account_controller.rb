class AccountController < ApplicationController

  def sign_up
  end

  def mypage
  end

  def new_account
    new_user = User.create(name: params[:acount_name], password: "password")
    userid = new_user.id
     ac = Account.create(name: params[:acount_name], mail: params[:mail], password: params[:password], user_id: userid)
     flash[:notice] = "アカウントを作成しました！"
     redirect_to("/account/#{ac.id}")
  end
end
