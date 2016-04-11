name "rubygem-mini_portile2"

require_relative "../../files/chef-dk-gem/build-chef-dk-gem/gem-install-software-def"
extend BuildChefDKGem::GemInstallSoftwareDef

dependency "libxml2"
dependency "libxslt"
dependency "libiconv"
dependency "liblzma"
dependency "zlib"

build do
  install_gem
  appbundle_gem
end

# gem installs this gem from the version specified in chef-dk's Gemfile.lock
# so we can take advantage of omnibus's caching. Just duplicate this file and
# add the new software def to chef-dk software def if you want to separate
# another gem's installation.
require_relative "../../files/chef-dk-gem/build-chef-dk-gem/"
BuildChefDKGem::GemInstallSoftwareDef.define(self, __FILE__) do
  # Extra build steps
  block "Remove mini_portile test dir" do
    mini_portile = shellout!("#{bundle_bin} show mini_portile").stdout.chomp
    remove_directory File.join(mini_portile, "test")
  end
end
