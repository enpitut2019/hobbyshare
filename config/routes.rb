Rails.application.routes.draw do
  get 'user/select' => 'user#select'
  get 'user/home'
end
