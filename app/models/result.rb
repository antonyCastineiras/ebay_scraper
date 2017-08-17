class Result < ApplicationRecord
	serialize :page
  belongs_to :ebay_scrape

  validates :title, uniqueness: true

  def result_page
  	a = Mechanize.new
  	a.get(self.href)
  end

  def set_page
  	update_attribute(:page, result_page.body) if !self[:page].present?
  end

  def page
  	Nokogiri::HTML(self[:page])
  end

  def condition
  	page.css('#vi-itm-cond').text
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
end
