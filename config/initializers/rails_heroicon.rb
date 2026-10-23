# The gem's railtie touches ActionView::Base while the app boots, which loads Action View early
# (a warning on every rake task). Load it once Action View loads instead.
ActiveSupport.on_load(:action_view) do
  require "rails_heroicon"
  include RailsHeroicon::Helper
end
