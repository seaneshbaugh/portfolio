FactoryGirl.define do
  factory :user do
    sequence :email do |n|
      "user#{n}@seaneshbaugh.com"
    end

    sequence :first_name do |n|
      "First Name #{n}"
    end

    sequence :last_name do |n|
      "Last Name #{n}"
    end

    password 'sufficientlylongpassword'

    password_confirmation 'sufficientlylongpassword'

    role Ability::ROLES[:read_only]

    trait :read_only do
      role Ability::ROLES[:read_only]
    end

    trait :admin do
      role Ability::ROLES[:admin]
    end

    trait :sysadmin do
      role Ability::ROLES[:sysadmin]
    end

    factory :read_only_user, :traits => [:read_only]
    factory :admin_user, :traits => [:admin]
    factory :sysadmin_user, :traits => [:sysadmin]
  end
end
