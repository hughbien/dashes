Gem::Specification.new do |s|
  s.name        = 'dashes'
  s.version     = '0.0.2'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Hugh Bien']
  s.email       = ['hugh@hughbien.com']
  s.homepage    = 'https://github.com/hughbien/dashes'
  s.summary     = 'Good looking charts for your terminal.'
  s.description = 'Format data into a dashboard of charts/tables on the command line.'
 
  s.required_rubygems_version = '>= 1.3.6'
  s.add_development_dependency 'minitest'
 
  s.files         = Dir.glob('*.{md}') +
                    Dir.glob('{lib,test}/*.rb')
  s.require_paths = ['lib']
end
