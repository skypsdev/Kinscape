module Concern
  module Box
    class << self
      def get_parents(box, result = [])
        result.unshift({ id: box.id, parent_id: box.parent_box_id, name: box.name })
        box.parent_box_id ? get_parents(box.parent_box, result) : result
      end
    end
  end
end
