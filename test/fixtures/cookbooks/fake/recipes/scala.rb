application 'scala' do
  path '/srv/scala'
  action :force_deploy

  owner 'vagrant'
  group 'vagrant'

  packages ['git']
  repository 'https://github.com/heroku/scala-sample.git'

  compile do
    buildpack_repository 'https://github.com/heroku/heroku-buildpack-scala.git'
  end

  scale do
    web 1
  end
end
