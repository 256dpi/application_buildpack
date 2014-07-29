application 'nodejs' do
  path '/srv/nodejs'
  action :force_deploy

  packages ['git']
  repository 'https://github.com/heroku/node-js-sample.git'

  buildpack do
    buildpack_repository 'https://github.com/heroku/heroku-buildpack-nodejs.git'
  end
end
