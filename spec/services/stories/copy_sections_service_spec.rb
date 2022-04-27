require 'spec_helper'

describe Stories::CopySectionsService do
  subject(:result) { described_class.call(new_story, original_story) }

  let(:user) { create :user }
  let(:original_story) { create :story, user: user }
  let(:image_blob1) { create_file_blob(filename: 'image.jpg') }
  let(:image_blob2) { create_file_blob(filename: 'image_2.png') }
  let(:rich_body) { ActionText::Content.new('some text').append_attachables(image_blob1) }
  let(:rich_body2) { ActionText::Content.new('some text').append_attachables(image_blob2) }
  let!(:section) { create :section, author: user, story: original_story, rich_body: rich_body }
  let!(:section2) { create :section, author: user, story: original_story, rich_body: rich_body2 }
  let!(:new_story) { create :story, user: user, original_story: original_story }

  it 'creates sections in new_story' do
    expect { result }.to change(Section, :count)
      .by(2)
      .and change(ActiveStorage::Attachment, :count)
      .by(2)
      .and change(ActionText::RichText, :count)
      .by(2)
      .and avoid_changing(ActiveStorage::Blob, :count)
    expect(new_story.sections.pluck(:original_section_id)).to contain_exactly(section.id, section2.id)
  end

  context 'with one section already copied' do
    before do
      new_story.sections << section.dup.tap do |dup_section|
        dup_section.original_section = section
        dup_section.rich_body = section.rich_body.dup
      end
    end

    it 'creates  only new sections in new_story' do
      expect { result }.to change(Section, :count)
        .by(1)
        .and change(ActiveStorage::Attachment, :count)
        .by(1)
        .and change(ActionText::RichText, :count)
        .by(1)
        .and avoid_changing(ActiveStorage::Blob, :count)
      expect(new_story.sections.pluck(:original_section_id)).to contain_exactly(section.id, section2.id)
    end
  end
end
