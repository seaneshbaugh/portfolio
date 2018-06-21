# frozen_string_literal: true

module Admin
  module AdminHelper
    def gem_dependencies
      lockfile = Bundler::LockfileParser.new(Bundler.read_file(Rails.root.join('Gemfile.lock')))

      lockfile.specs.map do |spec|
        {
          name: spec.name,
          version: spec.version.version,
          dependencies: spec.dependencies.map { |dependency| { name: dependency.name, requirement: dependency.requirement } }
        }
      end
    end

    def git_repo
      @git_repo ||= Git.open(Rails.root)
    end

    def git_branch
      git_repo.current_branch
    end

    def git_commit_sha
      git_repo.log.first.sha
    end
  end
end
