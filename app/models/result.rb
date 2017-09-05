class Result < ApplicationRecord
  include Filterable

	serialize :page
  belongs_to :ebay_scrape

  scope :price_order, -> (value) { order price: value }
  scope :format, -> (format) { where format: format }
  scope :condition, -> (condition) { where condition: condition }

  validates :title, uniqueness: true

  after_commit :set_page, on: :create

  def condition
    self[:condition] || 'getting details...'
  end

  def result_page
  	a = Mechanize.new
  	a.get(self.href)
  end

  def set_page
  	ResultPageJob.perform_later(self) if self[:page].blank?
  end

  def page
  	Nokogiri::HTML(self[:page])
  end

  def update_page_attributes
    update_attributes(condition: condition_from_page)
  end

  def condition_from_page
  	page.css('#vi-itm-cond').text
  end

  def deviation
    (price - ebay_scrape.average_price_of_results).abs
  end

  def deviation_rating
    average_deviation = ebay_scrape.average_deviation_of_result_price
    deviation <= average_deviation ? 5 : 0
  end

  def search_rating
  	rating = 0
  	rating += search_words_count
  	rating += exact_match_rating if is_exact_match?
  	rating
  end

  def search_words
  	ebay_scrape.search_words
  end

  def search_words_count
  	search_words.inject(0) { |sum, word| sum += title.downcase.scan(word).count }
  end

  def is_exact_match?
  	title.downcase.scan(ebay_scrape.search.downcase).count > 0
  end

  def exact_match_rating
  	5
  end

  def contains_all_search_words?
    a = search_words.collect { |search_word| title.downcase.include?(search_word.downcase) }
    a.all? { |b| b == true }
  end
end
