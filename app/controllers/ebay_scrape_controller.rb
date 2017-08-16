class EbayScrapeController < ApplicationController
  def new
  	@ebay_scrape = EbayScrape.new
  end

  def create
  	@ebay_scrape = EbayScrape.create(ebay_scrape_params)
  	redirect_to ebay_scrape_path(@ebay_scrape)
  end

  def show
  	@ebay_scrape = EbayScrape.find(params[:id])
  end

  def update
  end

  private

  def ebay_scrape_params
  	params.require(:ebay_scrape).permit(:search)
  end
end
