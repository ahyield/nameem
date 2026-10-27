namespace :seo do
  desc "Give older articles a readable URL slug and a fuller search description"
  task backfill: :environment do
    puts "Updated #{Article.backfill_seo} articles"
  end
end
