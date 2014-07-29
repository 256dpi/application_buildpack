include ApplicationCookbook::ResourceBase

attribute :buildpack_repository, :kind_of => [String, NilClass], :default => nil
attribute :buildpack_revision, :kind_of => [String], :default => 'master'
