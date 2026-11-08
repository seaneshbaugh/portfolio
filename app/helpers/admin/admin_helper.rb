# frozen_string_literal: true

module Admin
  module AdminHelper
    def creatable_models
      @creatable_models ||= [ Post, Page, Picture, Gallery, Link, User ].select do |model|
        policy([ :admin, model ]).create?
      end
    end

    def cancel_icon(options = {})
      icon(:close)
    end

    def cancel_icon_link(url_or_path, options = {})
      link_to(url_or_path, class: info_button_class, aria: { label: options[:label] || t("cancel") }) do
        label = options[:label].to_s if options[:label]

        cancel_icon(class: { "left" => label }) + label
      end
    end

    def delete_icon(options = {})
      icon(:delete)
    end

    def delete_icon_link(url_or_path, options = {})
      link_to(url_or_path, class: warning_button_class, aria: { label: options[:label] || t("delete") }, rel: "nofollow", data: { turbo_method: :delete, turbo_confirm: t("confirm_delete") }) do
        label = options[:label].to_s if options[:label]

        delete_icon(class: { "left" => label }) + label
      end
    end

    def edit_icon(options = {})
      icon(:edit)
    end

    def edit_icon_link(url_or_path, options = {})
      link_to(url_or_path, class: success_button_class, aria: { label: options[:label] || t("edit") }) do
        label = options[:label].to_s if options[:label]

        edit_icon(class: { "left" => label }) + label
      end
    end

    def gem_dependencies
      lockfile = Bundler::LockfileParser.new(Bundler.read_file(Rails.root.join("Gemfile.lock")))

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

    def search_icon(options = {})
      icon(:search)
    end

    def yarn_version
      `yarn -v`
    end
  end
end
