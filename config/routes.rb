Rails.application.routes.draw do
 resources :ebay_scrape
 post '/ebay_scrape/:id/update_results' => 'ebay_scape#update_results', as: :update_results
 root 'ebay_scrape#new'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
