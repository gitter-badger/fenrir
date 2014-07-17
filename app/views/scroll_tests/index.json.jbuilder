json.array!(@scroll_tests) do |scroll_test|
  json.extract! scroll_test, :id, :title, :author, :body
  json.url scroll_test_url(scroll_test, format: :json)
end
