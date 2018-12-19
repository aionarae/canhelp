require './canhelplib'
require 'securerandom'
require 'pry'

module CanhelpPlugin
  include Canhelp

  def delete_enrollment(token, canvas_url, course_id, enrollment_id, task = "delete")
    canvas_delete("#{canvas_url}/api/v1/courses/#{course_id}/enrollments/#{enrollment_id}", token,
    {
      task: task
    })
  end

  def self.remove_enrollment(
    subdomain = prompt(:subdomain),
    user_id = prompt(:user_id)
  )
    token = get_token
    canvas_url = "https://#{subdomain}.instructure.com"

    puts canvas_url
    puts "#{canvas_url}/api/v1/users/#{user_id}/enrollments"
    puts "Finding enrollments..."

    enrollment_list = get_json_paginated(token,"#{canvas_url}/api/v1/users/#{user_id}/enrollments")

    puts "#{enrollment_list.count} enrollments found. Deleting..."

    enrollment_id = []
    enrollment_list.each do |e|
      enrollment_id << e['id']
      delete_enrollment(token, canvas_url, e['course_id'], e['id'], task = "delete")
      print "."
    end

    puts "Removed enrollment id(s):(#{enrollment_id})."

  end
end
