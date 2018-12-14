class AddSessionPoolSizeAndIdleTimeoutToVendor < ActiveRecord::Migration[5.2]
  def change
    add_column :vendors, :pool_size, :integer, default: 1
    add_column :vendors, :pool_idle, :integer, default: 10
  end
end
