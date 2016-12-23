Rails.application.routes.draw do
  post 'pay/notify'

  root to: "home#index"
end
