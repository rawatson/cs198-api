Rails.application.routes.draw do
  with_options(format: 'json', except: [:new, :edit]) do |opts|
    opts.resources :courses, except: [:new, :edit, :create, :update, :destroy]
    opts.resources :people, except: [:new, :edit, :create, :destroy] do
      opts.resources :courses, except: [:new, :edit, :create, :update, :destroy]
      opts.resources :lair_shifts, controller: :"lair/shifts", only: [:index, :create]
    end

    namespace :lair do
      get :status, to: "status#status", format: :json
      put :status, to: "status#update", format: :json

      opts.resources :helpers, except: [:new, :edit, :update] do
        member do
          opts.resources :helper_assignments, path: "assignments", only: [:index] do
            collection do
              get :current, to: "helpers#current_assignment"
            end
          end
        end
      end

      opts.resources :shifts, except: [:new, :edit, :show]

      opts.resources :help_requests do
        opts.resources :helper_assignments, path: "assignments", only: [:index, :create] do
          collection do
            get :current, to: "help_requests#current_assignment"
            post :reassign
            post :reopen
          end
        end
      end

      opts.resources :helper_assignments, only: [:show, :index, :create] do
        post :reassign
        post :reopen
      end
    end
  end

  match "(*path)", to: "application#options", via: [:options]
end
