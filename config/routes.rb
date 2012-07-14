MarcinCebula::Application.routes.draw do
 

  namespace :api do
    namespace :v1 do
      resources :examples, 
                :only => [:index, :create, :show, :update, :destroy], 
                :defaults => { :format => 'json' }
    end
  end
  
  
  resources :docs, :only => [:index]
  resources :blog, :only => [:index]

  root :to => 'blog#index'

end
