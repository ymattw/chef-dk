name "rubygem-berkshelf"

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
