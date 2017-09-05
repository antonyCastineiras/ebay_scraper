class ResultPageJob < ApplicationJob
  queue_as :default

  def perform(result)
    result.update_attribute(:page, result.result_page.body)
    result.update_page_attributes
  end
end
