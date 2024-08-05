# frozen_string_literal: true

require_relative 'lib/gem_error_codes/version'

Gem::Specification.new do |spec|
  spec.name = 'gem_error_codes'
  spec.version = GemErrorCodes::VERSION
  spec.authors = ['Seto Elkahfi']
  spec.email = ['setoelkahfi@gmail.com']

  spec.summary = 'Ruby binding error_codes from crate_error_codes.'
  spec.description = 'Write a longer description or delete this line.'
  spec.homepage = 'https://splitfire.ai/gem_error_codes'
  spec.required_ruby_version = '>= 3.0.0'
  spec.required_rubygems_version = '>= 3.3.11'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.extensions = ['ext/gem_error_codes/Cargo.toml']

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
