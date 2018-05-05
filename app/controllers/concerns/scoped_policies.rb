# frozen_string_literal: true

# See https://gist.github.com/coderliu/df69abc96cc0bc5098edb2ca4cab0651
module ScopedPolicies
  extend ActiveSupport::Concern

  included do
    helper_method :authorize
    helper_method :policy_scope
  end

  # These are workarounds for the lack of support for namespacing in pundit
  # https://github.com/elabs/pundit/issues/12
  # Ideally PolicyFinder should be extended instead, with the controller methods
  # simply passing things along.
  # This is super hacky and makes assumptions the original methods don't.
  def controller_namespace
    @controller_namespace ||= self.class.to_s.sub(/::[A-z]*Controller/, '')
  end

  def authorize(record, query = nil)
    klass = "#{controller_namespace}::#{record.model_name}Policy".constantize
    policy = klass.new(pundit_user, record)
    query ||= "#{params[:action]}?"

    @_policy_authorized = true

    unless policy.public_send(query)
      error = Pundit::NotAuthorizedError.new(t("#{policy.class.to_s.underscore}.#{query}", scope: 'pundit', default: :default))
      error.query, error.record, error.policy = query, record, policy
      raise error
    end

    true
  end

  def policy(record)
    klass = "#{controller_namespace}::#{record.model_name}Policy".constantize

    klass.new(pundit_user, record)
  rescue NameError => e
    nil
  end

  def policy!(record)
    raise NotDefinedError, 'unable to find policy of nil' if record.nil?

    policy or raise NotDefinedError, "unable to find policy `#{find}` for `#{object.inspect}`"
  end

  def policy_scope(scope)
    klass = "#{controller_namespace}::#{scope.model_name}Policy::Scope".constantize
    policy = klass.new(pundit_user, scope)

    @_policy_scoped = true

    policy.resolve
  end
end
