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
- `scale`: The number of processes to be started for each Procfile entry. Default: `{}`.
- `buildpack_repository`: A custom buildpack repository that should be used instead. Default: `nil`.
- `buildpack_revision`: The revision of the buildpack to be used. Default: `master`.
- `buildpack_environmet`: Additional ENV variables to be passed to the buidlpack compile script. Default: `{}`.

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
    scale web: 1
  end
end
```

## Troubleshoot

- If the buildpack fails to compile because some packages are missing, just define the packages in your `application` LWRP: `packages ['lib-imagemagick']`.
