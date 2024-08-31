# frozen_string_literal: true

# Create some users and asooociated articles

return unless Rails.env.development?

require "faker"

Faker::Config.default_locale = "ar"

puts "Creating users..."

# Create users
20.times do |i|
  puts "Creating user #{i + 1}"

  # make it thread safe and unique
  User.create!(
      email: Faker::Internet.unique.email,
      name: Faker::Name.unique.name[0..20],
      bio: Faker::Lorem.paragraph[0..200],
      last_sign_in_at: Time.zone.now,
      slug: Faker::Internet.unique.slug[0..20],
      confirmed: true,
      featured: false,
      avatar: Rails.root.join("spec", "fixtures", "files", "avatar-#{rand(1..6)}.jpeg").open
  )
end

# Create articles
User.all.each do |user|
  puts "Creating articles for user #{user.id}"
  5.times do |i|
    user.articles.create do |article|
      article.title = Faker::Lorem.sentence

      # Attach the image separately
      image_attachment = article.images.attach(
        io: Rails.root.join("spec", "fixtures", "files", "avatar-#{rand(1..6)}.jpeg").open,
        filename: "image-#{(1..900).to_a.sample}.jpeg"
      ).first

      # Save the article to persist the image attachment
      article.save!

      # Use the attached image URL in the article content
      article.update!(
        content: {
          ops: [
            { insert: { customImage: { url: Rails.application.routes.url_helpers.rails_blob_url(image_attachment, only_path: true) } } },
            { insert: "\n" },
            { insert: Faker::Lorem.sentence(word_count: 50) },
            { insert: Faker::Lorem.sentence(word_count: 100) },
            { insert: "\n" },
            { insert: Faker::Lorem.sentence(word_count: 50) },
            { insert: Faker::Lorem.sentence(word_count: 100) },
            { insert: "\n" },
            { insert: Faker::Lorem.sentence(word_count: 50) },
            { insert: Faker::Lorem.sentence(word_count: 100) },
            { insert: "\n" },
            { insert: Faker::Lorem.sentence(word_count: 50) },
            { insert: Faker::Lorem.sentence(word_count: 100) }
          ]
        },
        published: true,
        uuid: SecureRandom.uuid,
        featured: [true, false].sample,
        picked: [true, false].sample,
        published_at: Time.zone.now
      )
    end
  end
end

# Make some users easily identifiable
puts "Making some users easily identifiable..."
User.first.update!(name: "محمد عبد الله", email: "a@a.com", admin: true)
User.second.update!(name: "أحمد محمود", email: "b@b.com", admin: true)

# make some articles featured
puts "Updating articles..."
Article.all.sample(10).each do |article|
  article.update!(featured: true)
end

# Pick some users
puts "Picking users..."
User.all.sample(5).each do |user|
  user.update!(picked: true, featured: true)
end

puts "Done...."
