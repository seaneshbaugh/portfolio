# frozen_string_literal: true

module Admin
  module AdminHelper
    def creatable_models
      @creatable_models ||= [Post, Page, Picture, Gallery, Link, User].select do |model|
        policy([:admin, model]).create?
      end
    end

    def cancel_icon(options = {})
      tag.i('clear', class: classnames('material-icons', options[:class]))
    end

    def cancel_icon_link(url_or_path, options = {})
      link_to(url_or_path, class: warning_button_class) do
        label = options[:label].to_s if options[:label]

        cancel_icon(class: { 'left' => label }) + label
      end
    end

    def delete_icon(options = {})
      tag.i('delete_forever', class: classnames('material-icons', options[:class]))
    end

    def delete_icon_link(url_or_path, options = {})
      link_to(url_or_path, class: warning_button_class, rel: 'nofollow', method: :delete, data: { confirm: t('confirm_delete') }) do
        label = options[:label].to_s if options[:label]

        delete_icon(class: { 'left' => label }) + label
      end
    end

    def edit_icon(options = {})
      tag.i('edit', class: classnames('material-icons', options[:class]))
    end

    def edit_icon_link(url_or_path, options = {})
      link_to(url_or_path, class: success_button_class) do
        label = options[:label].to_s if options[:label]

        edit_icon(class: { 'left' => label }) + label
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

    def node_version
      `nodejs -v`
    end

    def quick_links_column_width
      @quick_links_column_width ||= 12 / creatable_models.length
    end

    def quick_links_offset
      @quick_links_offset ||= (12 % (creatable_models.length * quick_links_column_width)) / 2
    end

    def search_icon(options = {})
      tag.i('search', class: classnames('material-icons', options[:class]))
    end

    def yarn_version
      `yarn -v`
    end
  end
end
