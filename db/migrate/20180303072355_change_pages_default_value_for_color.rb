# frozen_string_literal: true

class ChangePagesDefaultValueForColor < ActiveRecord::Migration[5.1]
  def change
    reversible do |dir|
      dir.up do
        change_column_default :pages, :color, '#000000'
      end

      dir.down do
        change_column_default :pages, :color, ''
      end
    end
  end
end
