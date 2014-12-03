Rails.application.routes.draw do
  with_options(format: 'json', except: [:new, :edit]) do |opts|
    opts.resources :people, except: [:new, :edit, :create, :destroy]

    namespace :lair do
      get :status, to: "status#status", format: :json
      put :status, to: "status#update", format: :json

      opts.resources :helpers, except: [:new, :edit, :update] do
        member do
          # get a single helper's shifts
          opts.resources :shifts

          opts.resources :helper_assignments, path: "assignments", only: [:index] do
            collection do
              get :current, to: "helpers#current_assignment"
            end
          end
        end

        collection do
          # get total helper schedule
          opts.get :shifts
        end
      end

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
