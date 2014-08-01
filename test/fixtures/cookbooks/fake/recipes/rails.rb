application 'rails' do
  path '/srv/rails'
  action :force_deploy

  owner 'vagrant'
  group 'vagrant'

  packages ['git']
  repository 'https://github.com/heroku/ruby-rails-sample.git'

  environment 'PORT' => 8000

  compile do
    buildpack :ruby
  end

  scale do
    web 1
  end
end
