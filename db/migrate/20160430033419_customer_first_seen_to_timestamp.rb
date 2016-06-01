class CustomerFirstSeenToTimestamp < ActiveRecord::Migration
  def change
    rename_column :customers, :first_purchase, :first_purchase_at
    change_column :customers, :first_purchase_at, :integer

    # In Postgres, changing a datetime column to epoch integer would be like:
    # change_column :customers, :first_purchase_at, "integer using cast(date_part('epoch', first_purchase_at) as integer);"
  end
end
