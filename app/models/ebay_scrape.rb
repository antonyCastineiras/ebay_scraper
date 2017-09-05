class EbayScrape < ApplicationRecord
	serialize :object # need to remove object from model
	has_many :results

	after_create :scrape_ebay, :set_average_price_of_results, :set_average_deviation_of_result_price

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
		first_page = agent.get( search_page_href(1) )
		pages_count = number_of_pages( first_page )

		pages_count == 0 ? i = 0 : i = 1
		while ( i <= pages_count ) do
			page = agent.get( search_page_href(i) )
			page_results( page ).each { |result| results << result  }
			i += 1
		end

		results.flatten
	end

	def number_of_pages(page)
		page.css('td.pages a.pg').present? ? page_numbers = page.css('td.pages a.pg').last.text.to_i : 0  
	end

	def create_results(search_results)
		search_results.each { |sresult| 
			result = 	Result.new( result_arguments(sresult) )
			result.save if result.contains_all_search_words?
			
			#if the result already exists adds a reference to it
			results << Result.where(title: result.title) if !result.persisted?
			break if results.count >= max_number_of_results
		}
	end

	def scrape_ebay
		results = search_results
		create_results( results )
	end

	def result_arguments(result)
		{ebay_scrape: self, title: result_title(result), price: result_price(result), format: result_format(result), shipping: result_shipping(result), href: result_href(result)}
	end

	def search_page_href(page_number)
		home_page_url + '/sch/?_nkw=' + key_words_string + '&_pgn=' + page_number.to_s + '&_ipg=200'
		# &LH_Complete=1&LH_Sold=1
	end

	def page_results(page)
		page.css('.sresult')
	end

	def search_words
		search.split(" ")
	end

	def key_words_string
		search_words.map { |search_word| search_word + "+" }.join
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

	def set_average_price_of_results
		update_attribute( :average_price_of_results, average_price(results) ) if results.any?
	end

	def set_average_deviation_of_result_price
		update_attribute( :average_deviation_of_result_price, average_deviation_of_price ) if results.any? 
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
		if new_items.count > 0
			results = new_items.select { |result| result.format.downcase == 'buy it now' }
			recommended_price(results)
		else
			0.00
		end
	end

	def used_recommended_price(results)
		if results.count > 0
			# results = used_items.select { |result| result.format.downcase == 'buy it now'  }
			recommended_price(results)
		else
			0.00
		end
	end

	def recommended_price(results)
		ad = calculate_average_deviation(self.results)
		ap = average_price(results)
		selected_results = results.select { |result| (result.price - ap).abs <= ad }
		selected_results.count > 0 ? average_price(selected_results).floor - 0.01 : 0.00
	end

	def calculate_average_deviation(results)
		results.inject(0) { |sum,result| sum += ( result.price - average_price(results) ).abs } / number_of_results
	end

	def used_items
		results.select { |result| result.condition.downcase.include?('used') }
	end

	def new_items
		results.select { |result| result.condition.downcase == 'new' }
	end

	def finished_updating?
		results.all? { |result| result[:page].present? }
	end

	def average_deviation_of_price
		results.inject(0) { |sum,result| sum += (result.price - average_price_of_results).abs } / number_of_results
	end
end
