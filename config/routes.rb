Rails.application.routes.draw do
 resources :ebay_scrape
 root 'ebay_scrape#new'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
