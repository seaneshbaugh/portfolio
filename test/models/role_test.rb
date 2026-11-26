# frozen_string_literal: true

require "test_helper"

class RoleTest < ActiveSupport::TestCase
  test "role identity is unique within global class and instance scopes including nulls" do
    scopes = [ {}, { resource_type: "Gallery" }, { resource: galleries(:salt_plains) } ]

    scopes.each do |scope|
      attributes = Role.create!({ name: "scoped-editor" }.merge(scope)).attributes.except("id")

      assert_raises ActiveRecord::RecordNotUnique do
        Role.transaction(requires_new: true) { Role.insert_all!([ attributes ]) }
      end
    end

    assert_equal 3, Role.where(name: "scoped-editor").count
  end

  test "blank names and resource ids without a type fail validation and database checks" do
    [ { name: nil }, { name: "" }, { name: " \t\n" }, { name: "editor", resource_id: 123 } ].each do |attributes|
      role = Role.new(attributes)

      assert_not role.valid?
      assert role.errors[attributes[:resource_id] ? :resource_type : :name].any?

      assert_raises ActiveRecord::StatementInvalid do
        Role.transaction(requires_new: true) { Role.insert_all!([ role.attributes.except("id") ]) }
      end
    end
  end

  test "Rolify grants and removes each scope independently and preserves shared roles" do
    user = users(:sean_eshbaugh)
    other_user = users(:casie_clark)
    scopes = [ nil, Gallery, galleries(:salt_plains) ]

    scopes.each { |scope| user.add_role(:reviewer, scope) }

    role_ids = Role.where(name: "reviewer").ids

    assert_equal 3, role_ids.size

    scopes.each { |scope| other_user.grant(:reviewer, scope) }

    assert_equal role_ids.sort, other_user.roles.where(name: "reviewer").ids.sort

    user.remove_role(:reviewer, galleries(:salt_plains))

    assert_equal 2, user.roles.where(name: "reviewer").count
    assert_equal role_ids.sort, Role.where(name: "reviewer").ids.sort

    other_user.remove_role(:reviewer, galleries(:salt_plains))

    assert_equal 2, Role.where(name: "reviewer").count
    assert_equal 2, other_user.roles.where(name: "reviewer").count
  end

  test "assignment columns are required and repeated role links are rejected by the database" do
    user = users(:sean_eshbaugh)
    role = roles(:admin)

    [ [ nil, role.id ], [ user.id, nil ] ].each do |user_id, role_id|
      assert_raises ActiveRecord::NotNullViolation do
        Role.transaction(requires_new: true) { insert_assignment(user_id, role_id) }
      end
    end

    assert_raises ActiveRecord::RecordNotUnique do
      Role.transaction(requires_new: true) { insert_assignment(user.id, role.id) }
    end
  end

  test "repeated grants recover from stale association state without duplicate assignments" do
    [ :add_role, :grant ].each do |method|
      user = User.find(users(:sean_eshbaugh).id)
      user.roles.load
      winner = User.find(user.id)
      role = winner.add_role("stale-#{method}")

      assert_equal role.id, user.public_send(method, role.name).id
      assert_equal role.id, user.public_send(method, role.name).id
      assert_equal 1, user.roles.where(id: role.id).count
    end
  end

  private

  def insert_assignment(user_id, role_id)
    connection = Role.connection
    connection.execute("INSERT INTO users_roles (user_id, role_id) VALUES (#{connection.quote(user_id)}, #{connection.quote(role_id)})")
  end
end
