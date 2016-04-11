extend Omnibus::Software::Rubygem

dependency "libxml2"
dependency "libxslt"
dependency "libiconv"
dependency "liblzma"
dependency "zlib"

build do
  install_gem

  # Extra build steps
  block "Remove mini_portile test dir" do
    mini_portile = shellout!("#{bundle_bin} show mini_portile").stdout.chomp
    remove_directory File.join(mini_portile, "test")
  end
end
