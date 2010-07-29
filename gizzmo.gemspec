# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{gizzmo}
  s.version = "0.4.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Kyle Maxwell"]
  s.date = %q{2010-07-29}
  s.default_executable = %q{gizzmo}
  s.description = %q{Gizzmo is a command-line client for managing gizzard clusters.}
  s.email = %q{kmaxwell@twitter.com}
  s.executables = ["gizzmo"]
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "bin/gizzmo",
     "gizzmo.gemspec",
     "lib/gizzard.rb",
     "lib/gizzard/commands.rb",
     "lib/gizzard/thrift.rb",
     "lib/gizzmo.rb",
     "lib/vendor/thrift_client/simple.rb",
     "test/config.yaml",
     "test/expected/deep.txt",
     "test/expected/dry-wrap-table_b_0.txt",
     "test/expected/empty-file.txt",
     "test/expected/find-only-sql-shard-type.txt",
     "test/expected/forwardings.txt",
     "test/expected/help-info.txt",
     "test/expected/info.txt",
     "test/expected/links-for-replicating_table_b_0.txt",
     "test/expected/links-for-table_b_0.txt",
     "test/expected/links-for-table_repl_0.txt",
     "test/expected/original-find.txt",
     "test/expected/subtree-info.txt",
     "test/expected/subtree.txt",
     "test/expected/unwrapped-replicating_table_b_0.txt",
     "test/expected/unwrapped-table_b_0.txt",
     "test/expected/wrap-table_b_0.txt",
     "test/helper.rb",
     "test/recreate.sql",
     "test/test.sh"
  ]
  s.homepage = %q{http://github.com/twitter/gizzmo}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{Gizzmo is a command-line client for managing gizzard clusters.}
  s.test_files = [
    "test/helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end

