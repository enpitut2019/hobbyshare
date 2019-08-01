Rails.application.routes.draw do
  get 'user/select' => 'user#select'
<<<<<<< Updated upstream
  post 'user/show' => 'user#show'
=======
  get 'user/#id/show' => 'user#show'
>>>>>>> Stashed changes
  get 'user/home'
end
