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
  	params.require(:ebay_scrape).permit(:search, :max_number_of_results)
  end

  def set_ebay_scrape_variables
  	@ebay_scrape = EbayScrape.find(params[:id])
  	@results = @ebay_scrape.results.filter( filter_params )
  end	

  def filter_params
  	params.slice(:format, :price_order, :condition)
  end
end
