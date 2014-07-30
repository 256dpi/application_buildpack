include ApplicationCookbook::ResourceBase

attribute :language, kind_of: [Symbol], default: nil
attribute :buildpack_repository, kind_of: [String, NilClass], default: nil
attribute :buildpack_revision, kind_of: [String], default: 'master'
attribute :buildpack_environment, kind_of: [Hash], default: {}
attribute :scale, kind_of: [Hash], default: {}
