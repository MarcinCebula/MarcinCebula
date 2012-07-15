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
  
  get "blogs/chef_recipies"
  get "blogs/setup_hosted_chef"

  root :to => 'blog#index'

end
