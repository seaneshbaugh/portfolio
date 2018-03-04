# frozen_string_literal: true

class RemoveDefaultsFromPages < ActiveRecord::Migration[5.1]
  def change
    reversible do |dir|
      dir.up do
        change_column_default :pages, :slug, nil
      end

      dir.down do
        change_column_default :pages, :slug, ''
      end
    end
  end
end
