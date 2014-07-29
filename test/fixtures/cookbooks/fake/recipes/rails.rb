application 'rails' do
  path '/srv/rails'
  action :force_deploy

  packages ['git']
  repository 'https://github.com/heroku/ruby-rails-sample.git'

  buildpack do
    buildpack_repository 'https://github.com/heroku/heroku-buildpack-ruby.git'
  end
end
