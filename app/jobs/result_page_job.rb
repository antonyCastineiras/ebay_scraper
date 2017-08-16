class ResultPageJob < ApplicationJob
  queue_as :default

  def perform(result)
    result.update_attribute(:page, result.result_page.body)
  end
end
