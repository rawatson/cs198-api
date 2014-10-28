Rails.application.routes.draw do
  namespace :lair do
    resources :helpers, except: [:new, :edit] do
      member do
        # get a single helper's shifts
        resources :shifts, except: [:new, :edit]
      end

      collection do
        # get total helper schedule
        get :shifts
      end
    end

    resources :help_requests, except: [:new, :edit]
  end
end
