# application\_buildpack

## Description

This cookbook is designed to be able to deploy applications using heroku buildpacks.

Note that this cookbook is based on the `application` cookbook; you will find general documentation in that cookbook.

## Requirements

Chef 11.0.0 or higher required (for Chef environment use).

The following Opscode cookbooks are dependencies:

* application

## Resources/Providers

The LWRP provided by this cookbook is not meant to be used by itself; make sure you are familiar with the `application` cookbook before proceeding.

### `buildpack`

The `buildpack` sub-resource LWRP deals with compiling an app using a buildpack.

#### Attribute Parameters

- `language`: The language to be used. Will be used to install dependencies and set the buildpack repository. Default: `nil`.
- `buildpack_repository`: A custom buildpack repository that should be used instead. Default: `nil`.
- `buildpack_revision`: The revision of the buildpack to be used. Default: `master`.
- `buildpack_environmet`: Additional ENV variables to be passed to the buidlpack compile script. Default: `{}`.

### `scale`

The `buildpack` sub-resource LWRP deals with configuring monit to start processes described in your Procfile.

#### Attribute Parameters

You can pass any attribute combination to `scale` the name of the attribute will be matched to a process describe in your Procfile.

```ruby
scale do
  # scale with one process
  web 1
end

scale do
  # send a custom signal on reload to gracefully stop the process
  web 1, reload: 'USR1'
end
```

## Usage

A sample recipe that deploy a Ruby app:

```ruby
application 'example' do
  path '/srv/example'

  owner 'ubuntu'
  group 'ubuntu'

  packages ['git']
  repository 'https://github.com/heroku/ruby-rails-sample.git'

  buildpack do
    language :ruby
  end
  
  scale do
    web 1
  end
end
```

A sample recipe that deploys an scala app using a custom buildpack

```ruby
application 'example' do
  path '/srv/example'

  owner 'ubuntu'
  group 'ubuntu'

  packages ['git']
  repository 'https://github.com/heroku/scala-sample.git'

  buildpack do
    buildpack_repository 'https://github.com/heroku/heroku-buildpack-scala.git'
  end
  
  scale do
    web 1
  end
end
```

## Troubleshoot

- If the buildpack fails to compile because some packages are missing, just define the packages in your `application` LWRP: `packages ['lib-imagemagick']`.
- If the buildpack fails to compile due to a missing `/app` directory then the buidlpack uses hardcoded heroku paths. Create an issue on the repository or fork it. 
