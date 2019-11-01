Rails.application.routes.draw do

  get 'user/select' => 'user#select'
  get 'user/show/:user_id/:group_id' => 'user#show'
  get 'user/mypage/:user_id' => 'user#mypage'
  get 'user/first_setting/:user_id' => 'user#first_setting'
  get 'user/login' => 'user#login'
  post '/user/hobby_delete' => 'user#hobby_delete'

  get '/' => 'group#top'
  get '/top' => 'group#top'
  get 'group/enter' => 'group#enter'
  get 'group/search' => 'group#enter'
  post 'group/search' => 'group#search'
  get 'group/:group_id/list' => 'group#list'
  get 'group/make' => 'group#make'
  get 'group/new' => 'group#make'
  post 'group/new' => 'group#new'

  post 'user/newhobby' => 'user#newhobby'
  post 'user/name_change' => 'user#name_change'
  post 'user/group_password' => 'user#group_password'
  post 'user/first_password' => 'user#first_password'
  post 'user/group_login' => 'user#group_login'
  post 'user/new_member' => 'user#new_member'
  post 'user/group_delete' => 'user#group_delete'

  get 'account/sign_up' => 'account#sign_up'
  get 'account/:account_id' => 'account#mypage'
  post 'account/new_account' => 'account#new_account'
end
