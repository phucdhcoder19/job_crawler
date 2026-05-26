class CreateJobs < ActiveRecord::Migration[8.1]
  def change
    create_table :jobs do |t|
      t.string :title, null: false
      t.string :company_name
      t.string :salary
      t.string :location
      t.string :job_url, null: false
      t.datetime :posted_at
      t.text :description
      t.string :source, null: false, default: "vietnamworks"

      t.timestamps
    end

    add_index :jobs, :job_url, unique: true
    add_index :jobs, :location
    add_index :jobs, :company_name
  end
end
