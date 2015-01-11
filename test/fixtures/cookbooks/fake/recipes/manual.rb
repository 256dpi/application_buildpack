application 'manual' do
  path '/srv/manual'
  action :force_deploy

  owner 'vagrant'
  group 'vagrant'

  packages ['git']
  repository 'https://github.com/foreverjs/forever.git'

  compile do
    buildpack :nodejs
  end

  scale do
    whatever 1, run: 'while true; do sleep 2; done'
  end
end
