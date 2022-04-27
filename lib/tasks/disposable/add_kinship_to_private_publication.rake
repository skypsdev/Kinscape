desc 'Private Family'
task add_kinship_to_private_publication: :environment do
  Publication.private_type.where(kinship_id: nil).find_each do |publication|
    publication.update(kinship_id: publication.user.private_kinship.id)
  end
end
