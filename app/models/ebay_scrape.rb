class EbayScrape < ApplicationRecord
	serialize :object # need to remove object from model
	has_many :results, -> { order(created_at: :asc) }

	after_create :create_results

	def home_page_url
		'https://www.ebay.co.uk'
	end

	def agent(args = {})
		Mechanize.new(args)
	end

	def mechanize_homepage
		agent.get(home_page_url)
	end

	def search_input(page)
		page.forms.first.field_with(name: '_nkw')
	end

	def submit_button(page)
		page.forms.first.buttons.first
	end

	def ebay_search_page 
		page = mechanize_homepage
		search_input(page).value = self.search
		page.forms.first.submit
	end

	def results_page
		ebay_search_page
	end

	def search_results
		results = []
		i = 1
		while (results.length < result_limit && i < 3) do
			href = search_page_href(i)
			page = agent.get(href)
			results += page_results(page)
			i += 1
		end
		results.flatten
	end

	def search_page_href(page_number)
		home_page_url + '/sch/?_nkw=' + key_words_string + '&_pgn=' + page_number.to_s + '&_ipg=200'
	end

	def page_results(page)
		page.css('.sresult')
	end

	def result_limit
		40
	end

	def search_words
		search.split(" ")
	end

	def key_words_string
		search_words.map { |search_word| search_word + "+" }.join
	end

	def create_results
		search_results.each {|sresult| 
			result = Result.create(
				ebay_scrape: self, 
				title: result_title(sresult), 
				price: result_price(sresult), 
				format: result_format(sresult), 
				shipping: result_shipping(sresult), 
				href: result_href(sresult)
			)
			#if the result already exists adds a reference to it
			results << Result.where(title: result.title) if !result.persisted?
	}
	end

	def result_title(sresult)
		sresult.css('.lvtitle').text.strip
	end

	def result_price(sresult)
		sresult.css('.lvprice').text.strip.remove('£',',').to_f
	end

	def result_format(sresult)
		text = sresult.css('.lvformat').text.strip
		text.include?('bids') ? 'auction' : 'buy it now'
	end

	def result_shipping(sresult)
		sresult.css('.lvshipping').text.strip.remove(" ", "£", "+", "postage").to_f
	end

	def result_href(sresult)
		sresult.css('.lvtitle').children.find(name: :a).first.attributes["href"].value
	end

	def average_price(results)
		number_of_results = results.count
		price = total_price(results)
		(price / number_of_results).round(2)
	end

	def total_price(results)
		results.inject(0) { |sum,result| sum + result.price }
	end

	def number_of_results
		results.count
	end

	def most_expensive_result(results)
		results.max_by(&:price)
	end

	def cheapest_result(results)
		results.min_by(&:price)
	end

	def result_titles
		results.collect(&:title)
	end

	def closest_match
		results.max_by(&:search_rating)
	end


	def new_recommended_price
		mer = most_expensive_result(results)
		dif = ( mer.price - average_price(results) ).floor
		( mer.price - (dif / 2) ).floor - 0.01
	end

	def used_recommended_price
		if used_items.count > 0
			results = used_items
			average = average_price(results)
			mer = most_expensive_result(results)
			dif = ( mer.price - average ).floor
			( mer.price - (dif / 2) ).floor - 0.01
		end
	end

	def used_items
		results.select { |result| result.condition.downcase.include?('used') }
	end

	def finished_updating?
		results.all? { |result| result[:page].present? }
	end
end
