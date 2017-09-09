require 'net/http'
require 'pry'
require 'json'

module Canhelp
  def get_token
    File.open('.token').read
  end

  def get_json(token, url)
    uri = URI(url)
    req = Net::HTTP::Get.new(uri)
    req['Authorization'] = "Bearer #{token}"

    http = Net::HTTP.new(uri.hostname, uri.port)
    http.use_ssl = true
    res = http.request(req)

    JSON.parse(res.body)
  end

  def get_json_paginated(token, url)
    all_items = []
    page = 1
    while (!(items_on_page = get_json(token, "#{url}?recursive=true&per_page=100&page=#{page}")).empty?)
      all_items += items_on_page
      page += 1
    end
    return all_items
  end
end