class AddKinshipToPublication < ActiveRecord::Migration[6.1]
  def change
    add_reference :publications, :kinship
    add_reference :chapters, :kinship
    add_reference :sections, :kinship
  end
end
