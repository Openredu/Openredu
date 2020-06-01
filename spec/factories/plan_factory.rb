# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :plan do
    state "active"
    sequence(:name){ |n| "Plano #{n}"}
    video_storage_limit 1024
    members_limit 30
    file_storage_limit 1024
    association :billable, :factory => :course
    association :user
    current true
  end

  factory :active_package_plan, :class => :package_plan do
    state "active"
    sequence(:name) { |n| "Package Plan #{n}" }
    video_storage_limit 1024
    members_limit 20
    file_storage_limit 1024
    association :billable, :factory => :course
    association :user
    current true
  end
end
