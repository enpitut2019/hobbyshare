class AccountController < ApplicationController

  def sign_up
  end

  def mypage
  end

  def new_account
     ac = Account.create(name: params[:name], mail: params[:mail], password: params[:password])
     flash[:notice] = "アカウントを作成しました！"
     redirect_to("/account/#{ac.id}")
  end
end
