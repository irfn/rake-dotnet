#cli spec
require 'spec'
require 'fileutils'
require File.join(File.dirname(__FILE__), '..', 'lib', 'cli.rb')

describe Cli do
	before(:all) do
		@here = File.dirname(__FILE__)
		Dir.chdir('spec')
	end
	after :all do
		Dir.chdir('..')
	end
	it "should push nil onto the array of search paths" do
		cli = Cli.new
		cli.search_paths.should == [nil]
	end
	it "should push nil onto the array of search paths as the last item" do
		cli = Cli.new({:search_paths=>['foo']})
		cli.search_paths.should == ['foo', nil]
	end
	it "should not search for exe if it's specified in the params" do
		cli = Cli.new({:exe=>'foo', :search_paths=>['bar']})
		cli.cmd.should == '"foo"'
	end
	it "should search for exe if we have an exe_name but no exe, and return exe_name (because we want it to look within system-path)" do
		cli = Cli.new({:exe_name=>'foo'})
		cli.cmd.should == '"foo"'
	end
	it "should return fully qualified path to exe when search-path is tried and exe is found there successfully" do
		cli = Cli.new({:exe_name => 'foo.exe', :search_paths=>['support/cli']})
		cli.cmd.should match(/#{@here}.*/)
		cli.cmd.should include('support/cli/foo.exe')
	end
	it "should return fully qualified path to exe at first find when search-path is tried and exe is found" do
		cli = Cli.new({:exe_name => 'foo.exe', :search_paths=>['support/cli/bar', 'support/cli']})
		cli.cmd.should match(/#{@here}.*/)
		cli.cmd.should include('support/cli/bar/foo.exe')
	end
	it "should return fq path to exe at first find, skipping non-finds" do
		cli = Cli.new({:exe_name => 'foo.exe', :search_paths=>['support/cli/notexist', 'support/cli']})
		cli.cmd.should match(/#{@here}.*/)
		cli.cmd.should include('support/cli/foo.exe')
	end
	it "should throw if no exe found in search paths supplied and not in path" do
		cli = Cli.new({:exe_name => 'nonexistent'})
	end
end