namespace :announcements do
  desc "Tell readers dark mode is here: counts by default; TO=email sends a test copy; SEND=1 sends to «أخبار نميم» subscribers"
  task dark_mode: :environment do
    Announcements::DarkMode.new.run(to: ENV.fetch("TO", nil), deliver: ENV["SEND"] == "1", force: ENV["FORCE"] == "1")
  end
end
