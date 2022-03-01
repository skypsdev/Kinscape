class AddDescriptionToFamily < ActiveRecord::Migration[6.1]
  def change
    add_column :families, :description, :text

    Family.find_each do |family|
      html = family.profile.body&.to_html
      next if html.nil?

      family.update!(description: SanitizerService.call(html))
    end
  end
end
