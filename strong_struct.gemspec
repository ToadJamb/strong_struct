Gem::Specification.new do |spec|
  spec.name        = 'strong_struct'
  spec.version     = '0.0.1'
  spec.authors     = ['Travis Herrick']
  spec.email       = ['tthetoad@gmail.com']
  spec.summary     = 'OpenStruct-like classes with strong attributes'
  spec.description = '
    A structure that has strong attributes
  '.strip
  spec.homepage    = 'http://www.bitbucket.org/ToadJamb/strong_struct'
  spec.license     = 'LGPLV3'

  spec.files       = Dir['lib/**/*.rb', 'license/*']

  spec.extra_rdoc_files << 'readme.md'

  spec.add_dependency 'activemodel'

  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rake_tasks'
  spec.add_development_dependency 'gems'
  spec.add_development_dependency 'cane'
  spec.add_development_dependency 'rspec'
end
