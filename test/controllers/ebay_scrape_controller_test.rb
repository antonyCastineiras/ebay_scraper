require 'test_helper'

class EbayScrapeControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get ebay_scrape_new_url
    assert_response :success
  end

  test "should get create" do
    get ebay_scrape_create_url
    assert_response :success
  end

  test "should get update" do
    get ebay_scrape_update_url
    assert_response :success
  end

end
