class ChangeBoxNameLimit < ActiveRecord::Migration[6.1]
  def change
    Box.find_each do |box|
      next if box.name.length < 51

      box.update(name: box.name.truncate(50, omission: ''))
    end
    
    change_column :boxes, :name, :string, null: false, limit: 50
  end
end
