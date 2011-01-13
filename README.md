# Jira for Ruby

## Prerequisites 
SVN HEAD version of SOAP4R [http://dev.ctor.org/soap4r](http://dev.ctor.org/soap4r) is required.

## Build
    gem build jira4r.gemspec

## Installation

    gem install *.gem
    sudo gem install *.gem

## Quick start

### Authorization:
	jira = Jira4R::JiraTool.new(2, "http://example.com/jira/")
    jira.login("robot", "robot")

### Creating issue:
    issue = Jira4R::V2::RemoteIssue.new
    issue.project = "AAA"
    issue.type = "1"
	
    issue.summary = "Some text"
    issue.assignee = "robot" # Login
    jira.createIssue(issue)

### Creating issue and define components or other special objects:
    issue = Jira4R::V2::RemoteIssue.new
    issue.project = "AAA"
    issue.type = "1"
	
	component = Jira4R::V2::RemoteComponent.new(10000)

	componentlist = Jira4R::V2::ArrayOf_tns1_RemoteComponent.new 
	componentlist.push(component) 

	issue.components = componentlist	
    issue.summary = "Some text"
    issue.assignee = "robot" # Login
    jira.createIssue(issue)
	
To add special objects to issue like components or you have to create an instance of object Jira4R::V2::ArrayOf_tns1_*** and pass it to component variable in issue object.

### Create an unassigned issue 

    issue.assignee = ""

Bear in mind that in your JIRA setting you must allow creating unassigned issues.

## Other functionality

All Jira's SOAP APIs are exposed via Jira4R. In addtion, Jira4R exposes these methods:

* getProjectNoScheme( projectKey )
* getProject( projectKey )
* getNotificationScheme( notificationSchemeName )
* getGroup( groupName )
* getGroupRoleByName( projectRoleName )
* createPermissionScheme( name, description )
* getPermissionScheme( permissionSchemeName )
* getNotificationScheme( notificationSchemeName )
* getPermission( permissionName )
* findPermission( allowedPermissions, permissionName )
* fineEntityInPermissionMapping( permissionMapping, entityName )
* setPermissions( permissionScheme, allowedPermissions, entity ) 

## Some examples

[Code examples](http://svn.rubyhaus.org/jira4r/trunk/examples/)