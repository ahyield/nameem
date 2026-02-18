FactoryBot.define do
  factory :magic_link do
    user
    purpose { :sign_in }

    trait :sign_up do
      purpose { :sign_up }
    end

    trait :confirm_email do
      purpose { :confirm_email }
    end

    trait :expired do
      expires_at { 1.hour.ago }
    end
  end
end
