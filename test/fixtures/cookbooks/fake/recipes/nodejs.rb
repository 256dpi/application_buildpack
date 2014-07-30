application 'nodejs' do
  path '/srv/nodejs'
  action :force_deploy

  owner 'vagrant'
  group 'vagrant'

  packages ['git']
  repository 'https://github.com/heroku/node-js-sample.git'

  buildpack do
    language :nodejs
  end
end
