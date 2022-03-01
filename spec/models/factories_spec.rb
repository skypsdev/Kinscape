require 'spec_helper'

FactoryBot.factories.map(&:name).each do |factory_name|
  next if factory_name == :active_storage_attachment

  describe "factory #{factory_name}" do
    it 'is valid' do
      factory = create(factory_name)
      if factory.respond_to?(:valid?)
        result = factory.valid?
        expect(result).to be_truthy, factory.errors.full_messages.join(',')
        pp factory_name if factory.invalid?
      end
    end
  end
end
