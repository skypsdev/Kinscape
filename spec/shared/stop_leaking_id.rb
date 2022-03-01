shared_examples 'stop_leaking_foreign_key' do |subj, foreign, type = :foreign|
  it "#{subj} serializer does not include real #{foreign}.id in belong_to relation" do
    subject, foreign_obj = SerializerFactory.populate_foreign(described_class, subj, foreign)

    # Final check if we do not expose id values
    case type
    when :foreign
      expect(nested_hash_value(subject, "#{foreign}_id".to_sym)).not_to eq(foreign_obj.id)
      expect(nested_hash_value(subject, "#{foreign}_id".to_sym)).to eq(foreign_obj.uid)
    when :relation
      expect(subject.dig(:data, :relationships, foreign, :data, :id)).not_to eq(foreign_obj.id.to_s)
      expect(subject.dig(:data, :relationships, foreign, :data, :id)).to eq(foreign_obj.uid)
    end
  end
end

shared_examples 'stop_leaking_foreign_key_through' do |subj, foreign, through|
  it "#{subj} serializer does not include real #{foreign}.id in through relation" do
    subject, foreign_obj = SerializerFactory.populate_foreign_through(described_class, subj, foreign, through)

    expect(nested_hash_value(subject, "#{foreign}_id".to_sym)).not_to eq(foreign_obj.id)
    expect(nested_hash_value(subject, "#{foreign}_id".to_sym)).to eq(foreign_obj.uid)
  end
end

shared_examples 'stop_leak_id_in_has_many' do |subj, foreign|
  it "#{subj} serializer does not include real #{foreign}.id in has_many" do
    subject, foreign_obj = SerializerFactory.populate_has_many(described_class, subj, foreign)

    rel_name = foreign.to_s.pluralize.to_sym

    expect(subject.dig(:data, :relationships, rel_name, :data).first[:id]).not_to eq(foreign_obj.id.to_s)
    expect(subject.dig(:data, :relationships, rel_name, :data).first[:id]).to eq(foreign_obj.uid)
  end
end
