#
# Copyright:: Copyright (c) 2014 Chef Software Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'chef-dk/command/base'
require 'chef-dk/exceptions'
require 'chef-dk/component_test'
require 'chef-dk/chef_runner'

module ChefDK
  module Command
    class Desktop < ChefDK::Command::Base

      include ChefDK::Helpers

      banner "Usage: chef desktop [options]"

      option :verbose,
        :long         => "--verbose",
        :description  => "Display detailed output"

        option :cookbook,
          long:         "--cookbook COOKBOOK_PATH",
          description:  "Path to your desktop cookbook",
          default:      "~/.chefdk/desktop"

      def initialize(*args)
        super
        @desktop_cookbook_path = "~/.chefdk/desktop/cookbooks"
        @desktop_cookbook_name = "chef-desktop"
        @recipe = "default"
      end

      # An instance of ChefRunner. Calling ChefRunner#converge will trigger
      # convergence and generate the desired code.
      def chef_runner
        @chef_runner ||= ChefRunner.new(@desktop_cookbook_path, ["recipe[#{@desktop_cookbook_name}::#{@recipe}]"])
      end

      def run(params)
        puts "Running Chef Desktop"
        chef_runner.converge
      end
    end
  end
end
