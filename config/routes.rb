Rails.application.routes.draw do
  get 'user/select' => 'user#select'
  get 'user/show/:user_id/:group_id' => 'user#show'
  get 'user/mypage/:user_id' => 'user#mypage'
  get 'user/login' => 'user#login'
  get '/' => 'user#login'

  get 'group/:group_id/list' => 'group#list'
end
