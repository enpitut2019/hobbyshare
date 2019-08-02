Rails.application.routes.draw do
  get 'user/select' => 'user#select'
  #post 'user/show' => 'user#show'
  get 'user/show'
  get 'user/home'
end
