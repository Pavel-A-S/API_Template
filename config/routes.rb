Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get '/', to: redirect('api-docs')

  scope '/api/v1' do
    resources :players, only: [:show], controller: 'api/v1/players'
    resources :markets, only: [:show], controller: 'api/v1/markets'
    resources(
      :advertisements,
      only: %i[index create], controller: 'api/v1/advertisements'
    )
    resources :lots, only: [], controller: 'api/v1/lots' do
      member do
        put :for_sale
        put :ship_to_player
        put :recall
      end
    end
  end
end
