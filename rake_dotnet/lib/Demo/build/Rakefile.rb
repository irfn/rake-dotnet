# Documentation: http://rake.rubyforge.org/ -> Files/doc/rakefile.rdoc
require 'rake'
require 'rake/tasklib'
require '../../assemblyinfo.rb'
require '../../defaults.rb'
require '../../fxcop.rb'
require '../../harvester.rb'
require '../../msbuild.rb'
require '../../ncover.rb'
require '../../package.rb'
require '../../svn.rb'
require '../../version.rb'
require '../../xunit.rb'

PRODUCT_NAME = ENV['PRODUCT_NAME'] ? ENV['PRODUCT_NAME'] : 'Demo'
COMPANY = ENV['COMPANY'] ? ENV['COMPANY'] : 'DemoCompany'
RDNVERSION = Versioner.new.get

# Documentation: http://rake_dotnet.rubyforge.org/ -> Files/doc/rake_dotnet.rdoc
#require '../../rake_dotnet.rb'

assembly_info_cs = File.join(SRC_DIR,'AssemblyInfo.cs')
Rake::AssemblyInfoTask.new(assembly_info_cs) do |ai|
	# TODO: Read {configuration, product, company} from Rakefile.yaml config file ?
	ai.product_name = PRODUCT_NAME
	ai.company_name = COMPANY
	ai.configuration = CONFIGURATION
	ai.version = RDNVERSION
end

bin_out = File.join(OUT_DIR, 'bin')
Rake::MsBuildTask.new({:verbosity=>MSBUILD_VERBOSITY, :deps=>[bin_out, :assembly_info]})

Rake::HarvestOutputTask.new({:deps => [:compile]})

Rake::XUnitTask.new({:options=>{:html=>true,:xml=>true}, :deps=>[:compile, :harvest_output]})
Rake::FxCopTask.new({:deps=>[:compile, :harvest_output]})
Rake::NCoverTask.new

demo_site = File.join(OUT_DIR, 'Demo.Site')
Rake::HarvestWebApplicationTask.new({:deps=>[:compile]})

Rake::RDNPackageTask.new(name='bin', version=RDNVERSION, {:in_dir=>bin_out, :deps=>[:harvest_output, :xunit]})
Rake::RDNPackageTask.new(name='Demo.Site', version=RDNVERSION, {:in_dir=>demo_site, :deps=>[:harvest_webapps, :xunit]})

task :default => [:compile, :harvest_output, :xunit, :package]