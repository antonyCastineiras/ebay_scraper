class EbayScrapeController < ApplicationController
	before_action :set_ebay_scrape_variables, only: [:show, :update]

	def new
  	@ebay_scrape = EbayScrape.new
  end

  def create
  	@ebay_scrape = EbayScrape.create(ebay_scrape_params)
  	redirect_to ebay_scrape_path(@ebay_scrape)
  end

  def show
  end

  def update
  	@finished = @ebay_scrape.finished_updating?
  end

  private

  def ebay_scrape_params
  	params.require(:ebay_scrape).permit(:search)
  end

  def set_ebay_scrape_variables
  	@ebay_scrape = EbayScrape.find(params[:id])
  	@results = @ebay_scrape.results
  	@average_price = @ebay_scrape.average_price(@results)
  	@most_expensive_result = @ebay_scrape.most_expensive_result(@results)
  	@cheapest_result = @ebay_scrape.cheapest_result(@results)
  	@closest_match = @ebay_scrape.closest_match
  end	
end
