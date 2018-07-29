# frozen_string_literal: true

module Admin
  module AdminHelper
    def creatable_models
      @creatable_models ||= [Post, Page, Picture, User].select do |model|
        policy([:admin, model]).create?
      end
    end

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

    def icon_delete_link(url_or_path)
      link_to(content_tag(:i, 'delete_forever', class: 'material-icons'), url_or_path, class: 'btn btn-flat waves-effect waves-light red darken-3', rel: 'nofollow', method: :delete, data: { confirm: t('confirm_delete') })
    end

    def icon_edit_link(url_or_path)
      link_to(content_tag(:i, 'edit', class: 'material-icons'), url_or_path, class: 'btn btn-flat waves-effect waves-light green darken-3')
    end

    def quick_links_column_width
      @quick_links_column_width ||= 12 / creatable_models.length
    end
  end
end
