require './canhelplib'
require 'csv'
require 'faker'
require_relative 'shared/actions.rb'
require_relative 'shared/actions_csv.rb'

module CanhelpPlugin
  include Canhelp

  #specify how many teachers and students
  #create user per section
  #for each section, add enrollments based on teacher_count and student_count
  #this will override any previous CSVs

  def self.csv_enrollments(
    subdomain = prompt(:subdomain),
    account_id = prompt(:account_id),
    teacher_count = prompt(:teacher_count),
    student_count = prompt(:student_count),
    ta_count = prompt(:ta_count),
    designer_count = prompt(:designer_count),
    observer_count = prompt(:observer_count),
    prefix = prompt(:prefix),
    state = prompt(:state),
    sis_import = prompt(:sis_import_true_or_false)
  )

    token = get_token

    t = "teacher"
    s = "student"
    ta = "ta"
    d = "designer"
    o = "observer"

    #get course ids and section sis ids for an account
    course_list = get_courses(subdomain,account_id)

    course_sis_ids = course_list.map do |c|
      c['sis_course_id']
    end

    section_hash = course_sis_ids.reduce({}) do |memo, sis_course_id|
      memo[sis_course_id] = get_sections(subdomain, "sis_course_id:#{sis_course_id}").map do |section|
        section["sis_section_id"]
      end
      memo
    end

    section_ids = section_hash.reduce([]) do |memo, mapping|
      memo.concat(mapping.last)
      memo
    end

    #file path
    teacher_user_csv="csv/teacher_users.csv"
    teacher_enrollment_csv="csv/teacher_enrollments.csv"
    student_user_csv="csv/student_users.csv"
    student_enrollment_csv="csv/student_enrollments.csv"
    ta_user_csv="csv/ta_users.csv"
    ta_enrollment_csv="csv/ta_enrollments.csv"
    designer_user_csv="csv/designer_users.csv"
    designer_enrollment_csv="csv/designer_enrollments.csv"
    observer_user_csv="csv/observer_users.csv"
    observer_enrollment_csv="csv/observer_enrollments.csv"

    create_users_and_enrollments_csv(subdomain,section_ids,teacher_user_csv,teacher_enrollment_csv,teacher_count,prefix,t,state,sis_import) unless teacher_count.nil? || teacher_count.to_i == 0

    create_users_and_enrollments_csv(subdomain,section_ids,student_user_csv,student_enrollment_csv,student_count,prefix,s,state,sis_import) unless student_count.nil? || student_count.to_i == 0

    create_users_and_enrollments_csv(subdomain,section_ids,ta_user_csv,ta_enrollment_csv,ta_count,prefix,ta,state,sis_import) unless ta_count.nil? || ta_count.to_i == 0

    create_users_and_enrollments_csv(subdomain,section_ids,designer_user_csv,designer_enrollment_csv,designer_count,prefix,d,state,sis_import) unless designer_count.nil? || designer_count.to_i == 0

    create_users_and_enrollments_csv(subdomain,section_ids,observer_user_csv,observer_enrollment_csv,observer_count,prefix,o,state,sis_import) unless observer_count.nil? || observer_count.to_i == 0
  end

end
