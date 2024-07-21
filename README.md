[![Specs](https://github.com/nameemhq/nameem/actions/workflows/_specs.yml/badge.svg)](https://github.com/nameemhq/nameem/actions/workflows/_specs.yml)

# X 

Writing platform, sorta like medium, but for Arabic.


# Components

- rails
- stimulus
- quilljs
- active_storage
- ...

# setup

You need ruby, you can use `mise install ruby 3.2.2`

- clone it
- `gem install bundler`
- `bundle install`
- `rails db:create && rails db:migrate`
- You need Proc runner, I use [Overmind](https://github.com/DarthSim/overmind), `overmind start Procfile.dev`
