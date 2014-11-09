Rails.application.routes.draw do
  with_options(format: 'json', except: [:new, :edit]) do |opts|
    namespace :lair do
      opts.resources :helpers, except: [:new, :edit, :update] do
        member do
          # get a single helper's shifts
          opts.resources :shifts
        end

        collection do
          # get total helper schedule
          opts.get :shifts
        end
      end

      opts.resources :help_requests
    end
  end
end
