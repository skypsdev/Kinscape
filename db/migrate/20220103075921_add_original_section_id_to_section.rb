class AddOriginalSectionIdToSection < ActiveRecord::Migration[6.1]
  def change
    add_reference :sections, :original_section
  end
end
