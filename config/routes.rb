Rails.application.routes.draw do
  get 'user/select' => 'user#select'
  post 'user/show' => 'user#show'
  get 'user/mypage' => 'user#mypage'
  get '/' => 'user#mypage'
end
