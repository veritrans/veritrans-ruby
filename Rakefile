require 'rubygems'

begin
  desc "Run Specs"
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
  puts "no rspec available"
end

desc "Generate documentation with sdoc"
task :doc do
  Bundler.with_clean_env do
    exec %{sdoc -i ./*.md ./lib/*.rb ./lib/veritrans/*.rb  -m "Veritrans Ruby Library"}
  end
end
