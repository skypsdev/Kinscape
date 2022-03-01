ActiveAdmin.register_page 'Dashboard' do
  menu priority: 1, label: proc { I18n.t('active_admin.dashboard') }

  content do
    columns do
      column do
        table do
          thead do
            tr do
              th 'Community Member and Administrator #'
              th 'Communities #'
              th 'Stories #'
              th 'Stogare used (approx.)'
            end
          end

          tbody do
            tr do
              td User.all.count
              td Family.all.count
              td Story.all.count
              td "#{count_used_storage} Gb"
            end
          end
        end
      end
    end
  end
end

private

def count_used_storage
  (MediaFile.pluck(:size).compact.sum(0.0) / 1.gigabyte).round(2)
end
