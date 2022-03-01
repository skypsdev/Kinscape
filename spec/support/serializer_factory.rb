# SerializerFactory is used to populate serializer with its dependencies and base model
# to check if UUID is present in serializer code and ID is not
class SerializerFactory
  class << self
    def populate_origin(serializer_klass, subj)
      subject_dependencies = {}

      # Create dependencies to build full object with dependencies then
      add_deps!(get_belongs(klass(subj)), subject_dependencies)

      # Create Model with its dependencies and then create Serializer based on this model
      subj_obj = FactoryBot.create(subj, subject_dependencies)
      subject = serializer_klass
                .new(subj_obj, params: subject_dependencies.merge(current_user: FactoryBot.create(:user)))
                .serializable_hash # See ResponseService

      [subject, subj_obj]
    end

    def populate_foreign(serializer_klass, subj, foreign)
      foreign_obj = FactoryBot.create(foreign)

      # Get model class and its associations
      subject_dependencies = { foreign => foreign_obj }

      # Create dependencies to build full object with dependencies then
      add_deps!(get_belongs(klass(subj)), subject_dependencies)

      [build_subject(serializer_klass, subj, subject_dependencies), foreign_obj]
    end

    def populate_foreign_through(serializer_klass, subj, foreign, through)
      foreign_obj = FactoryBot.create(foreign)
      through_obj = FactoryBot.create(through, foreign => foreign_obj)

      # Get model class and its associations
      subject_dependencies = { through.to_s.pluralize.to_sym => [through_obj] }

      # Create dependencies to build full object with dependencies then
      add_deps!(get_belongs(klass(subj)), subject_dependencies)

      [build_subject(serializer_klass, subj, subject_dependencies), foreign_obj]
    end

    def populate_has_many(serializer_klass, subj, foreign)
      foreign_obj = FactoryBot.create(foreign)

      # Get model class and its associations
      subject_dependencies = { foreign.to_s.pluralize.to_sym => [foreign_obj] }

      add_deps!(get_belongs(klass(subj)), subject_dependencies)

      [build_subject(serializer_klass, subj, subject_dependencies), foreign_obj]
    end

    private

    def klass(sym)
      sym.to_s.camelize.constantize
    end

    def build_subject(serializer_klass, subj, subject_dependencies)
      # Create Model with its dependencies and then create Serializer based on this model
      subj_obj = FactoryBot.create(subj, subject_dependencies)
      serializer_klass
        .new(subj_obj, params: subject_dependencies.merge(current_user: FactoryBot.create(:user)))
        .serializable_hash # See ResponseService
    end

    def get_belongs(klass)
      klass.reflect_on_all_associations(:belongs_to)
           .reject { |s| s.options[:optional] }
           .reject { |s| s.options[:polymorphic] }
    end

    def add_deps!(associations, deps_array)
      associations.each do |association|
        if association.options[:class_name].present? # For example, author_id can be really implemented by User model
          factory_name = association.options[:class_name].downcase.to_sym
        else
          factory_name = association.name
        end
        o = FactoryBot.create(factory_name)

        deps_array[association.name] ||= o
      end
    end
  end
end
