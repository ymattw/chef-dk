module OmnibusRubygems
  module GemSoftwareDefinition
    # Set by GemfileSoftwareDefinition
    attr_accessor :gemspec, :bundle_package_path

    def gem_name
      if name.start_with?("rubygem-")
        name[8..-1]
      else
        raise "Gem software definitions must start with rubygem-, e.g. rubygem-#{name}"
      end
    end

    #
    # Calculate a version string for the given gem.
    #
    # Includes the source if it's git or path. Takes Jenkins environment variables
    # into account if local path.
    #
    def version
      case gemspec.source
      when Bundler::Source::Rubygems
        gemspec.version
      when Bundler::Source::Path
        # Support jenkins info about our version, if available
        if ENV["GIT_URL"] && ENV["GIT_COMMIT"]
          "#{gemspec.version} at #{ENV["GIT_URL"]} (at #{ENV["GIT_REF"]}@ENV["GIT_COMMIT"])"
        else
          "#{gemspec.version} at #{gemspec.source}"
        end
      else
        "#{gemspec.version} at #{gemspec.source}"
      end
    end
  end
end
