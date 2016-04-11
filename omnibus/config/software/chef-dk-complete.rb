name "chef-dk-complete"

license :project_license

# For nokogiri - we want to build these early since they rarely change
dependency "libxml2"
dependency "libxslt"
dependency "libiconv"
dependency "liblzma"
dependency "zlib"

# For nokogiri - we want to build these early since they rarely change
dependency "libarchive"

# ruby and bundler and friends
dependency "ruby"
dependency "rubygems"
dependency "bundler"

dependency "chef-dk"
dependency "chef-dk-appbundle"
if windows?
  dependency "chef-dk-env-customization"
  dependency "chef-dk-powershell-scripts"
  # TODO can this be safely moved to before the chef-dk?
  # It would make caching better ...
  dependency "ruby-windows-devkit"
end
dependency "chef-dk-remove-docs"
dependency "rubygems-customization"
dependency "shebang-cleanup"
dependency "version-manifest"
dependency "openssl-customization"
dependency "clean-static-libs"
