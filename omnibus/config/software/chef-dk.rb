name "chef-dk"

extend OmnibusRubygems::GemfileSoftwareDefinition
gemfile "../Gemfile",
  without: %W{
    development
    test
    guard
    maintenance
    tools
    integration
    changelog
    no_#{Omnibus::Ohai["platform"]}
  },
  # The gems that take the longest to install (like native gems) go here.
  build_first: %w{
    dep-selector-libgecode
    ffi-yajl
    json
    nokogiri
    libyajl2
    ffi
    ruby-prof
    dep_selector
    nio4r
    byebug
    yajl-ruby
    hitimes
    debug_inspector
    binding_of_caller
  },
  # The gems that change the most frequently go here.
  build_last: %w{
    chef-config
    ohai
    chef
    chef-dk
  }

version gem_software_version("chef-dk")
license :project_license

# Stuff that will happen after all the gems go.
build do
  # Check that the final gemfile worked
  block { log.info(log_key) { "" } }
  bundle "check", env: env, cwd: File.dirname(shared_gemfile)
end
