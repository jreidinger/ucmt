Gem::Specification.new do |s|
  s.name        = 'ucmt'
  s.version     = '0.0.1'
  s.licenses    = ['GPL-2.0']
  s.summary     = "Universal configuration management tool"
  s.description = "A set of tools to generate configuration for various configuration management tools like salt or ansible."
  s.authors     = ["Josef Reidinger"]
  s.email       = 'jreidinger@suse.com'
  s.files       = Dir["lib/**/*.rb"]
  s.require_path = "lib"
  s.bindir      = "bin/"
  s.executables = Dir["{bin}/*"].map { |f| File.basename(f) }
  s.homepage    = 'https://github.com/jreidinger/ucmt'

  s.add_dependency "optimist", "~> 3.0"
  s.add_dependency "cheetah", "~> 0.5.2"
end
