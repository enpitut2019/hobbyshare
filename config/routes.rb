Rails.application.routes.draw do
  get 'user/select' => 'user#select'
  get 'user/show/:user_id/:group_id' => 'user#show'
  get 'user/mypage/:user_id' => 'user#mypage'
  get 'user/login' => 'user#login'

  get '/' => 'group#top'
  get 'group/:group_id/list' => 'group#list'
  get 'group/make' => 'group#make'
  post 'group/new' => 'group#new'
end
