module OmnibusRubygems
  class GemfileSoftwareDefiner
    #
    # Create a new GemfileSoftwareDefiner.
    #
    def initialize(project, gemfile_path, without: [])
      @gemfile_path = File.expand_path(relative_path, Omnibus::Config.project_root)
      if File.exist?("#{gemfile_path}.#{Omnibus::Ohai["platform"]}")
        @gemfile_path = "#{gemfile_path}.#{Omnibus::Ohai["platform"]}"
      end

      @without = without
    end

    attr_reader :gemfile_path, :without, :build_first, :build_last

    def create_software_definitions
      specs.each do |spec|
        gem_name = spec.name
        software_name = "rubygem-#{gem_name}"
        # Create the software definition if it's not there.
        software_path = Omnibus.software_path(software_name)
        if software_path.nil?
          software_path = File.join(Config.project_root, Config.software_dir, "#{software_name}.rb")
          IO.write(software_path, <<-EOM.gsub(/^\s*/, ''))
            name #{software_name.inspect}
            extend OmnibusRubygems::GemSoftwareDefinition
            gemfile #{gemfile_path.inspect}

            build do
              install_gem
            end
          EOM
        end
      end
    end

    private

    #
    # Download the actual gems via bundler.
    #
    def fetch_gems
      output_bundle_config
      bundle "package", "--all", "--no-install", "--cache-path", bundle_package_path
    end

    #
    # Add dependencies to the software definition.
    #
    def declare_dependencies(gem_name=nil)
      if gem_name
        spec_for(gem_name)
      end
    end

    #
    # Get the gemspec for the given gem.
    #
    def spec_for(gem_name)
      specs.find { |s| s.name == gem_name }
    end

    #
    # The location of the bundle package.
    #
    def bundle_package_path
    end

    def output_bundle_config
      if without
        without = without.dup
        # no_aix, no_windows groups
        without << "no_#{Omnibus::Ohai["platform"]}"
      end

      bundle_config = File.expand_path("../.bundle/config", gemfile)

      retries = 4
      jobs = 4
      block "Put build config into #{bundle_config}: #{ { without: without, retries: retries, jobs: jobs, frozen: frozen } }" do
        # bundle config build.nokogiri #{nokogiri_build_config} messes up the line,
        # so we write it directly ourselves.
        new_bundle_config = "---\n"
        new_bundle_config << "BUNDLE_WITHOUT: #{Array(without).join(":")}\n" if without
        new_bundle_config << "BUNDLE_RETRY: #{retries}\n" if retries
        new_bundle_config << "BUNDLE_JOBS: #{jobs}\n" if jobs
        new_bundle_config << "BUNDLE_FROZEN: '1'\n" if frozen
        create_file(bundle_config) { new_bundle_config }
      end
    end

    #
    # Gets the Bundler::Definition from loading both Gemfile and Gemfile.lock
    #
    def bundle
      @bundle ||= Bundler::Definition.build(gemfile_path, "#{gemfile_path}.lock", nil)
    end

    #
    # Get the dependencies in the Gemfile, excluding groups we don't want
    #
    def dependencies
      @dependencies ||= bundle.dependencies.select { |d| (d.groups & without).any? }
    end

    #
    # Get all locked specs for the given dependencies.
    #
    def specs
      # This is sacrilege: figure out a way we can grab the list of dependencies *without*
      # requiring everything to be installed or calling private methods ...
      @specs ||= bundle.resolve.for(bundle.send(:expand_dependencies, dependencies))
    end

    #
    # Compare two deps, putting the one that must be installed first, first.
    #
    def compare_deps(a, b)
      if depends_on(a, b)
        if depends_on(b, a)
          nil
        else
          # a depends on b, so put b first
          -1
        end
      elsif depends_on(a, b)
        # b depends on a, so put a first
        1
      else
        nil
      end
    end

    #
    # Find out whether one gem depends on another.
    #
    def depends_on(a, b)
      return true if a == b
      a.dependencies.each do |dep|
        return true if dep == b
        return true if depends_on(a, dep)
      end
      false
    end

    def bundle
      @bundle ||= begin
        old_frozen = Bundler.settings[:frozen]
        Bundler.settings[:frozen] = true
        begin
          bundle = Bundler::Definition.build(gemfile_path, lockfile_path, nil)
          without = without_groups
          dependencies = bundle.dependencies.reject { |d| (d.groups & without).any? }
        ensure
          Bundler.settings[:frozen] = old_frozen
        end
      end
    end

    def gemspec
      # This is sacrilege: figure out a way we can grab the list of dependencies *without*
      # requiring everything to be installed or calling private methods ...
      gemspec = gems_for(dependencies).find { |s| s.name == gem_name }
      if gemspec
        log.info(software.name) { "Using #{gem_name} version #{gemspec.version} from #{gemfile_path}" }
      elsif bundle.resolve.find { |s| s.name == gem_name }
        log.info(software.name) { "#{gem_name} not loaded from #{gemfile_path}, skipping"}
      else
        raise "#{gem_name} not found in #{gemfile_path} or #{lockfile_path}"
      end
      gemspec
    end
  end
end
