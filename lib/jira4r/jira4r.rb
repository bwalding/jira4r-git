################################################################################
#  Copyright 2007 Codehaus Foundation                                          #
#                                                                              #
#  Licensed under the Apache License, Version 2.0 (the "License");             #
#  you may not use this file except in compliance with the License.            #
#  You may obtain a copy of the License at                                     #
#                                                                              #
#     http://www.apache.org/licenses/LICENSE-2.0                               #
#                                                                              #
#  Unless required by applicable law or agreed to in writing, software         #
#  distributed under the License is distributed on an "AS IS" BASIS,           #
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.    #
#  See the License for the specific language governing permissions and         #
#  limitations under the License.                                              #
################################################################################

#Oh how I hate thee...
$: << File.dirname(__FILE__) + '/..'
require 'jira4r/jira_tool.rb'

#Due to refactoring, this class should no longer be used.
module Jira
  class JiraTool
    puts "Jira::JiraTool is deprecated; use Jira4R::JiraTool"
    
    def initialize(version, base_url)
      @proxy = ::Jira4R::JiraTool.new(version, base_url)
    end
    
    def method_missing(name, *args)
      @proxy.send(name, *args)
    end
  end
end
