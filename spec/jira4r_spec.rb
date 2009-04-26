require 'spec_helper'
require 'jira4r/jira_tool'

TEST_BASE_URL = 'http://localhost/'

describe Jira4R::JiraTool do
  it "should have an 'enhanced' attribute" do
    Jira4R::JiraTool.new(2,TEST_BASE_URL).should respond_to(:enhanced)
  end
end

