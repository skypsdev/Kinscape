shared_examples 'uuidable' do
  describe 'uuid' do
    subject { described_class }

    it 'has UUID and Uid by default' do
      expect(subject.new.uuid).to be_present
      expect(subject.new.uuid.class).to be(Integer)

      expect(subject.new.uid).not_to be_nil
      expect(subject.new.uid.class).to be(String)
    end

    it 'is findable by UUID' do
      f = FactoryBot.create(subject.to_s.downcase.to_sym)
      expect(subject.find_by(uuid: f.uuid)).to be_present
    end
  end
end
