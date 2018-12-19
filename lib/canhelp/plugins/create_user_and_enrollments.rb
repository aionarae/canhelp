require './canhelplib'
require 'securerandom'
require 'pry'
require 'faker'
require_relative 'shared/actions.rb'

module CanhelpPlugin
  include Canhelp
  include Actions

  def self.create_user_and_enrollment (
    subdomain = prompt(:subdomain),
    prefix = prompt(:prefix),
    count= prompt(:count),
    course_id = prompt(:course_id),
    user_id = prompt(:user_id),
    type = prompt(:type),
    state = prompt(:state),
    self_enroll = prompt(:self_enroll)
  )

    non_active = ['conclude', 'delete', 'inactivate', 'deactivate']
    enrollment_list = []

    if non_active.include? ("#{state}") || user_id.empty?
      active_state = "active"
      created_user_id = create_user(subdomain,
      prefix,
      count,
      type,
      state
    )

      created_user_id.each do |u|
        enrollment_list << create_enrollment(subdomain, course_id, u, type, active_state, self_enroll)

      end

      print "Setting enrollment(s) to #{state}..."
      enrollment_list.each do |e|
        update_enrollment(subdomain, e['course_id'], e['id'], state)
        print "."
      end
      puts "\nDone."

    elsif state.empty? || user_id.empty?
      created_user_id = create_user(
        subdomain,
        prefix,
        count,
        type,
        state
      )
      created_user_id.each do |u|
        create_enrollment(subdomain, course_id, u, type, state="active", self_enroll)
      end
      puts "Done."

    else
      created_user_id = create_user(
        subdomain,
        prefix,
        count,
        type,
        state
      )
      created_user_id.each do |u|
        create_enrollment(subdomain, course_id, u, type, state="active", self_enroll)
      end
      puts "Done."

    end

    if user_id.empty?
      created_user_id.each do |u|
        #random_state = ['active', 'invited', 'inactive'].sample(1)
        create_enrollment(subdomain, course_id, u, type, state, self_enroll)
      end
    else
      create_enrollment(subdomain, course_id, user_id, type, state, self_enroll)
    end

  end
end
