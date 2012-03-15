Coderipper::Application.routes.draw do
  get "home/index"

  root :to => 'home#index'
end
