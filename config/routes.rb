Rails.application.routes.draw do

  get 'user/show/:user_token' => 'user#show'
  get 'user/match/:user_id/:target_id' => 'user#match'
  get 'user/mypage/:user_token' => 'user#mypage'
  post '/user/dummyhobby_delete' => 'user#dummyhobby_delete'
  post '/user/hobby_delete' => 'user#hobby_delete'
  post '/user/account_hobby_delete' => 'user#account_hobby_delete'
  post '/user/similar_hobby' => 'user#similar_hobby'
  post '/user/similar_hobby_add' => 'user#similar_hobby_add'
  post '/user/similar_hobby_delete' => 'user#similar_hobby_delete'

  get '/' => 'group#top'
  get '/top' => 'group#top'
  get 'group/enter' => 'group#enter'
  get 'group/search' => 'group#enter'
  post 'group/search' => 'group#search'
  get 'group/list/:group_token' => 'group#list'
  get 'group/make' => 'group#make'
  get 'group/new' => 'group#make'
  post 'group/new' => 'group#new'
  get 'group/add_member/:group_token' => 'group#add_member'

  post 'user/newhobby' => 'user#newhobby'
  post 'user/account_newhobby' => 'user#account_newhobby'
  post 'user/ac_newhobbies' => 'user#ac_newhobbies'
  post 'user/dummy_newhobby' => 'user#dummy_newhobby'
  post 'user/name_change' => 'user#name_change'
  post 'user/new_member' => 'user#new_member'
  post 'user/delete' => 'user#user_delete'

  get 'account/sign_up' => 'account#sign_up'
  get 'account/login' => 'account#login'
  get 'account/logout' => 'account#logout'
  get 'account/:account_id' => 'account#mypage'
  post 'account/new_account' => 'account#new_account'
  get 'account/new_account' => 'account#sign_up'
  post 'account/login_process' => 'account#login_process'
  get 'account/login_process' => 'account#login'
end
