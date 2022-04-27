require 'spec_helper'

describe ::Stories::CreationService do
  subject(:result) { described_class.call(params, current_user) }

  let(:current_user) { create :user }

  context 'when a nil is passed' do
    let(:params) do
      {
        cover: image_blob,
        title: 'title',
        description: 'description',
        start_year: '2222',
        start_month: 'January',
        start_day: '2',
        end_year: '2223',
        end_month: 'December',
        end_day: '3',
        is_range: true,
        categories: ['holiday']
      }
    end
    let(:image_blob) { create_file_blob }

    it 'does create the story and publication' do
      expect { result }
        .to change(Story, :count)
        .by(1)
        .and change(Publication, :count)
        .by(1)
      expect(result).to have_attributes(params.except(:cover, :categories))
      expect(result.category_list).to eq(params[:categories])
      expect(result.publications.count).to eq(1)
      expect(result.publications.first.share_type).to eq('private')
    end

    context 'with image blob as empty string' do
      let(:image_blob) { '' }

      it 'does create the story and publication' do
        expect { result }
          .to change(Story, :count)
          .by(1)
          .and change(Publication, :count)
          .by(1)
        expect(result).to have_attributes(params.except(:cover, :categories))
        expect(result.category_list).to eq(params[:categories])
        expect(result.publications.first.share_type).to eq('private')
      end
    end
  end
end
