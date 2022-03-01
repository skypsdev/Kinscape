shared_examples 'uuid_in_serializer' do |baseclass|
  describe 'uid' do
    it 'provides uid as id' do
      subj, obj = SerializerFactory.populate_origin(described_class, baseclass)

      expect(subj[:data][:id]).to eq(obj.uid)
    end
  end
end
