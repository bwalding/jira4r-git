require 'net/http'
require 'fileutils'
require 'rake/clean'
require 'logger'

begin
  require 'rubygems'
  require 'rake/gempackagetask'
rescue Exception
  nil
end

gem 'soap4r'

require 'wsdl/soap/wsdl2ruby'

logger = Logger.new(STDERR)
logger.level = Logger::INFO


desc "gets the wsdl and generates the classes"
task :default => [:generate]



desc "gets the wsdl files for JIRA services"
task :getwsdl do
  versions().each { |version| 
    save(getWsdlFileName(version), get_file("test.jira.codehaus.org", "/rpc/soap/jirasoapservice-v#{version}?wsdl"))
  }
end

task :build_gem do
  system("gem build jira4r.gemspec")
end

task :clean do
  File.unlink("wsdl/jirasoapservice-v2.wsdl")
  File.unlink("lib/jira4r/v2/jiraService.rb")
  File.unlink("lib/jira4r/v2/jiraServiceDriver.rb")
  File.unlink("lib/jira4r/v2/jiraServiceMappingRegistry.rb")
end

task :install_gem do
  system("gem install *.gem")
end  

task :deploy_gem do
  system("scp *.gem codehaus03:/home/projects/jira4r/snapshots.dist/distributions/")
end

desc "generate the wsdl"
task :generate do
  versions().each { |version|
    wsdl = getWsdlFileName(version)
    basedir = "lib/jira4r/v#{version}"
    mkdir_p basedir

    if not File.exist?(wsdl)
      raise "WSDL does not exist: #{wsdl}"
    end
    wsdl_url = "file://#{File.expand_path(wsdl)}"

    # Create the server
    worker = WSDL::SOAP::WSDL2Ruby.new
    worker.logger = logger
    worker.location = wsdl_url
    worker.basedir = basedir
    worker.opt['force'] = true
    worker.opt['classdef'] = "jiraService"
    worker.opt['module_path'] ="Jira4R::V#{version}"
    
    worker.opt['mapping_registry'] = true
    #worker.run
    
    #Create the driver
    #worker = WSDL::SOAP::WSDL2Ruby.new
    #worker.logger = logger
    #worker.location = wsdl_url
    #worker.basedir = basedir
    #worker.opt['force'] = true
    #worker.opt['module_path'] = "Jira4R::V#{version}"

    worker.opt['driver'] = "JiraSoapService"
    worker.run
  }
end

def versions 
 [ 2 ]
end

def get_file(host, path)
    puts "getting http://#{host}#{path}"
    http = Net::HTTP.new(host)
    http.start { |w| w.get2(path).body }
end

def getWsdlFileName(vName)
  "wsdl/jirasoapservice-v#{vName}.wsdl"
end


# Saves this document to the specified @var path.
# doesn't create the file if contains markup for 404 page
def save( path, content )
  File::open(path, 'w') { | f | 
    f.write( content ) 
  }
end

def fix_soap_files(version)
  fix_require("lib/jira4r/v#{version}/jiraServiceMappingRegistry.rb")
  fix_require("lib/jira4r/v#{version}/JiraSoapServiceDriver.rb")
end

def fix_require(filename)
  content = ""
  File.open(filename) { |io| 
    content = io.read()
    
    content = fix_content(content, 'jiraService')
    content = fix_content(content, 'jiraServiceMappingRegistry')
  }
  
  File.open(filename, "w") { |io| 
    io.write(content)
  }
end

def fix_content(content, name)
  return content.gsub("require '#{name}.rb'", "require File.dirname(__FILE__) + '/#{name}.rb'")
end