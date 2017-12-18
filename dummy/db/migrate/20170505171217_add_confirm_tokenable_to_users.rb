class AddConfirmTokenableToUsers < ActiveRecord::Migration[5.0]
  def change
  
    add_column :users, :confirm_token, :string, default: nil
    add_column :users, :confirm_created_at, :timestamp, default: nil
    add_column :users, :confirm_sent_at, :timestamp, default: nil
    add_column :users, :confirm_completed_at, :timestamp, default: nil

    add_index :users, :confirm_token
  
    add_column :users, :reset_token, :string, default: nil
    add_column :users, :reset_created_at, :timestamp, default: nil
    add_column :users, :reset_sent_at, :timestamp, default: nil
    add_column :users, :reset_completed_at, :timestamp, default: nil

    add_index :users, :reset_token
  
    add_column :users, :invite_token, :string, default: nil
    add_column :users, :invite_created_at, :timestamp, default: nil
    add_column :users, :invite_sent_at, :timestamp, default: nil
    add_column :users, :invite_completed_at, :timestamp, default: nil

    add_index :users, :invite_token
  
  end
end
