Rails.application.routes.draw do
  get 'user/select' => 'user#select'
  get 'user/show' => 'user#show'
  get 'user/home'
end
