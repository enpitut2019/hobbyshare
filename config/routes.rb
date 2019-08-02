Rails.application.routes.draw do
  get 'user/select' => 'user#select'
  post 'user/show' => 'user#show'
  get 'user/mypage/:user_id' => 'user#mypage'
  get 'user/login' => 'user#login'
  get '/' => 'user#login'
end
