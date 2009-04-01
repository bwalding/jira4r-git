require 'logger'
require 'rubygems'
gem 'soap4r'

module Jira4R
  
  class JiraTool
    attr_accessor :enhanced
    
    # Create a new JiraTool
    # 
    # where:
    # version ... the version of the SOAP API you wish to use - currently supported versions  [ 2 ]
    # base_url ... the base URL of the JIRA instance - eg. http://confluence.atlassian.com
    def initialize(version, base_url)
      @version = version
      @base_url = base_url  
      @logger = Logger.new(STDERR)
      @endpoint_url = "#{@base_url}/rpc/soap/jirasoapservice-v#{version}"
    end
    
    #Assign a new logger to the tool. By default a STDERR logger is used.
    def logger=(logger)
      @logger = logger
    end
    
    #Retrieve the driver, creating as required.
    def driver()
      if not @driver
        @logger.info( "Connecting driver to #{@endpoint_url}" )

        require "jira4r/v#{@version}/jiraService.rb"
        require "jira4r/v#{@version}/JiraSoapServiceDriver.rb"
        require "jira4r/v#{@version}/jiraServiceMappingRegistry.rb"
        
        service_classname = "Jira4R::V#{@version}::JiraSoapService"
        puts "Service: #{service_classname}"
        service = eval(service_classname)
        @driver = service.send(:new, @endpoint_url)
      end
      @driver
    end
    
    #Assign a wiredump file prefix to the driver.
    def wiredump_file_base=(base)
      driver().wiredump_file_base = base
    end
    
  
    #Login to the JIRA instance, storing the token for later calls. 
    # 
    #This is typically the first call that is made on the JiraTool.
    def login(username, password)
      @token = driver().login(username, password)
    end

    #Clients should avoid using the authentication token directly.    
    def token()
      @token
    end
    
    #Call a method on the driver, adding in the authentication token previously determined using login()
    def call_driver(method_name, *args)
      @logger.debug("Finding method #{method_name}")
      method = driver().method(method_name)     
      
      if args.length > 0
        method.call(@token, *args)     
      else
        method.call(@token)
      end
    end
    
    #Retrieve a project without the associated PermissionScheme.
    #This will be significantly faster for larger Jira installations.
    #See: JRA-10660
    def getProjectNoScheme(key)
      puts "getProjectNoScheme is deprecated. Please call getProjectNoSchemes."
      getProjectNoSchemes(key)
    end
    
    def getProjectNoSchemes(key)
      self.getProjectsNoSchemes().find { |project| project.key == key }
    end
    
    def getProject(key)
      #Jira > 3.10 has been patched to support this method directly as getProjectByKey
      puts "Using deprecated JIRA4R API call getProject(key); replace with getProjectByKey(key)"
      return getProjectByKey(key)
    end
    
    def getProjectByKey( projectKey )
      begin
        return call_driver( "getProjectByKey", projectKey )
      rescue SOAP::FaultError => soap_error
        #XXX surely there is a better way to detect this kind of condition in the JIRA server
        if soap_error.faultcode.to_s == "soapenv:Server.userException" and soap_error.faultstring.to_s == "com.atlassian.jira.rpc.exception.RemoteException: Project: #{projectKey} does not exist"
          return nil
        else
          raise soap_error
        end
      end
    end
    
    def getGroup( groupName )
      begin
        return call_driver( "getGroup", groupName )
      rescue SOAP::FaultError => soap_error
        #XXX surely there is a better way to detect this kind of condition in the JIRA server
        if soap_error.faultcode.to_s == "soapenv:Server.userException" and soap_error.faultstring.to_s == "com.atlassian.jira.rpc.exception.RemoteValidationException: no group found for that groupName: #{groupName}"
          return nil
        else
          raise soap_error
        end
      end
    end
    
    def getProjectRoleByName( projectRoleName )
      getProjectRoles.each{ |projectRole|
        return projectRole if projectRole.name == projectRoleName
      }
    end
    
    def getPermissionScheme( permissionSchemeName )
      self.getPermissionSchemes().each { |permission_scheme| 
        return permission_scheme if permission_scheme.name == permissionSchemeName
      }
      return nil
    end
    
    def getNotificationScheme( notificationSchemeName )
      self.getNotificationSchemes().each { |notification_scheme| 
        return notification_scheme if notification_scheme.name == notificationSchemeName
      }
      return nil
    end
    
    def getPermission( permissionName )
      if not @permissions
        @permissions = self.getAllPermissions()
      end
      
      @permissions.each { |permission|
        return permission if permission.name.downcase == permissionName.downcase
      }
      
      @logger.warn("No permission #{permissionName} found")
      return nil
    end
    
    def findPermission(allowedPermissions, permissionName)
		allowedPermissions.each { |allowedPermission|
		   #puts "Checking #{allowedPermission.name} against #{permissionName} "
		   return allowedPermission if allowedPermission.name == permissionName
		}
		return nil    
    end
    
    def findEntityInPermissionMapping(permissionMapping, entityName)
      permissionMapping.remoteEntities.each { |entity|
	    return entity if entity.name == entityName
	  }
	  return nil
	end
    
    #Removes entity
    def setPermissions( permissionScheme, allowedPermissions, entity)
      allowedPermissions = [ allowedPermissions ].flatten.compact
      #Remove permissions that are no longer allowed
      permissionScheme.permissionMappings.each { |mapping|
        next unless findEntityInPermissionMapping(mapping, entity.name)
      
        allowedPermission = findPermission(allowedPermissions, mapping.permission.name)
	    if allowedPermission
  	      puts "Already has #{allowedPermission.name} in #{permissionScheme.name} for #{entity.name}"
		  allowedPermissions.delete(allowedPermission)
	      next
	    end

		puts "Deleting #{mapping.permission.name} from #{permissionScheme.name} for #{entity.name}"
        deletePermissionFrom( permissionScheme, mapping.permission, entity)
      }
      
      puts allowedPermissions.inspect
      allowedPermissions.each { |allowedPermission|
		puts "Granting #{allowedPermission.name} to #{permissionScheme.name} for #{entity.name}"
		addPermissionTo(permissionScheme, allowedPermission, entity) 
	  }   
    end

private
    def fix_args(args)
      args.collect { |arg|
        if arg == nil
          SOAP::SOAPNil.new
        else
          arg
        end
      }
    end
    
    def method_missing(method_name, *args)
      args = fix_args(args)
      call_driver(method_name, *args)
    end
    
    
  
  end  

end
