class RemoveSphinxDeltas < ActiveRecord::Migration
  def up
    remove_column :discussions, :delta
    remove_column :posts, :delta
  end

  def down
    add_column :discussions, :delta, :boolean, null: false, default: true
    add_column :posts, :delta, :boolean, null: false, default: true
  end
end
