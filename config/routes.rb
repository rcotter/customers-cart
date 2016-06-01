Rails.application.routes.draw do

  namespace :api do
    namespace :v1, defaults: {format: 'json'} do
      resources :customers, only: [:create, :index, :show] do
        resources :items, only: [:create, :update] # Grrrrr - how to disable PUT? Only PATCH is wanted.

        # NOTE: Items are only got as part of a customer. Unconventional but best in this case I think.
      end
    end
  end
end
