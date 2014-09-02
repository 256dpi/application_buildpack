application 'nodejs' do
  path '/srv/nodejs'
  action :force_deploy

  owner 'vagrant'
  group 'vagrant'

  packages ['git']
  repository 'https://github.com/heroku/node-js-sample.git'

  compile do
    buildpack :nodejs
  end

  scale do
    web 1
  end
end
