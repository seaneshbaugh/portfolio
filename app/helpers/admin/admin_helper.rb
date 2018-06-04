# frozen_string_literal: true

module Admin
  module AdminHelper
    def gem_dependencies
      lockfile = Bundler::LockfileParser.new(Bundler.read_file(Rails.root.join('Gemfile.lock')))

      lockfile.specs.map { |spec| { name: spec.name, version: spec.version.version, dependencies: spec.dependencies.map { |dependency| { name: dependency.name, requirement: dependency.requirement } } } }
    end
  end
end