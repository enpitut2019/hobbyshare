Rails.application.routes.draw do

  get 'user/select' => 'user#select'
  get 'user/show/:user_id/:group_id' => 'user#show'
  get 'user/mypage/:user_id' => 'user#mypage'
  get 'user/login' => 'user#login'
  post '/user/hobby-delete' => 'user#hobby_delete'

  get '/' => 'group#top'
  get '/top' => 'group#top'
  post 'group/search' => 'group#search'
  get 'group/:group_id/list' => 'group#list'
  get 'group/make' => 'group#make'
  post 'group/new' => 'group#new'
  post 'user/newhobby' => 'user#newhobby'
  post 'user/name_change' => 'user#name_change'
  post 'user/group_password' => 'user#group_password'
  post 'user/group_login' => 'user#group_login'
  post 'user/new_member' => 'user#new_member'
end
