class AccountController < ApplicationController

  def sign_up
  end

  def mypage
  end

  def new_account
    if Account.find_by(name: params[:name])
      flash[:notice] = "その名前はすでに使われています"#nameが既存のものと一致した場合は弾く
      redirect_to("/account/sign_up")
    else
     ac = Account.create(name: params[:name], mail: params[:mail], password: params[:password])
     flash[:notice] = "アカウントを作成しました！"
     redirect_to("/account/#{ac.id}")
   end
  end

  def login_process#セッションはまかせた
    login_name = Account.find_by(name: params[:name])
    if login_name && login_name.authenticate(params[:password])
      redirect_to("/account/#{login_name.id}")
    else
      flash[:notice] = "入力された内容に誤りがあります"#nameかpasswordが間違っている場合は弾く
      redirect_to("/account/login")
    end
  end
end
