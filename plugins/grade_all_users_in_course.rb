require './canhelplib'
module CanhelpPlugin
  include Canhelp

#grades all users in the course
#grades all assignments if assignment id is blank

  def grade_submission(token, canvas_url, course_id, assignment_id, user_id, grade)
    canvas_put("#{canvas_url}/api/v1/courses/#{course_id}/assignments/#{assignment_id}/submissions/#{user_id}", token, {
      submission: {
        posted_grade: grade
      }
    })
  end
  def self.grade_all_old(
    subdomain = prompt(:subdomain),
    course_id = prompt(:course_id),
    assignment_id = prompt(:assignment_id)
  )
    token = get_token
    canvas_url = "https://#{subdomain}.instructure.com"
    users = get_json_paginated(token, "#{canvas_url}/api/v1/courses/#{course_id}/users")
    puts "#{users.count} users found"
    user_ids = users.map do |user|
      user['id']
    end

    if assignment_id.empty?
      assignments = get_json_paginated(token, "#{canvas_url}/api/v1/courses/#{course_id}/assignments")
      assignments.each do |assignment|
        assignment_id = assignment['id']
        user_ids.each do |user_id|
          score = rand(10) + 1
          result = grade_submission(token, canvas_url, course_id, assignment_id, user_id, score)
          puts "User #{user_id} grade for Assignment #{assignment_id}: #{score}"
        end
      end

    else
      user_ids.each do |user_id|
        score = rand(10) + 1
        result = grade_submission(token, canvas_url, course_id, assignment_id, user_id, score)
        puts "User #{user_id} Grade for Assignment #{assignment_id}: #{score}"
      end
    end
  end
end
