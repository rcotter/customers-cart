class AddCustomersTable < ActiveRecord::Migration
  def change

    create_table :customers do |t|
      t.string :customer_id, null: false
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.date :date_of_birth, null: false
      t.date :first_purchase
      t.boolean :approved, null: false, default: false
      t.timestamps null: false
    end

    add_index :customers, [:customer_id], name: 'customers_on_customer_id', unique: true

    create_table :items do |t|
      t.string :item_id, null: false
      t.string :customer_id, null: false
      t.integer :amount_cents, null: false
      t.string :name, null: false
      t.string :status, null: false
      t.integer :purchased_at
      t.timestamps null: false
    end

    add_index :items, [:customer_id, :status, :purchased_at], name: 'items_on_customer_id_status_purchased_at', unique: true
  end
end
