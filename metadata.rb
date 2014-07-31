name 'application_buildpack'
version '0.0.1'
license 'MIT'

maintainer '256dpi'

description 'deploys and configures apps using heroku buildpacks'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))

depends 'monit'
depends 'application', '~> 4.0'
