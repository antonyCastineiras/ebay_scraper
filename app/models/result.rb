class Result < ApplicationRecord
	serialize :page
  belongs_to :ebay_scrape

  validates :title, uniqueness: true

  after_commit :set_page

  def result_page
  	a = Mechanize.new
  	a.get(self.href)
  end

  def set_page
  	ResultPageJob.perform_later(self)
  end

  def page
  	Nokogiri::HTML(self[:page])
  end

  def condition
  	page.css('#vi-itm-cond').text
  end
end
