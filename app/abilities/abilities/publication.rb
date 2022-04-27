module Abilities
  module Publication
    def default_publication
      can :read, ::Publication, { family_id: all_families_ids, publish_on: ..Time.zone.today }
      can :read, ::Publication, { family_id: all_families_ids, publish_on: nil }
      can :collaborate, ::Publication, { share_type: 'community', family_id: except_guested_ids }
      cannot :read, ::Publication, { family_id: nil }
      can :manage, ::Publication, { story: { user_id: user.id } }
      can :manage, ::Publication, { family_id: admin_families_ids }
      can :create_another, ::Publication, { family_id: [families_ids, nil] }
      cannot :create_another, ::Publication, { share_type: 'community' }
    end

    def super_admin_publication
      can :manage, ::Publication, { family_id: families_ids, publish_on: ..Time.zone.today }
      can :manage, ::Publication, { family_id: families_ids, publish_on: nil }
    end

    def showcase_publication
      can :read, ::Publication, { story: { user_id: user.id } }
      can :read, ::Publication, { family_id: families_ids, publish_on: nil }
      can :read, ::Publication, { family_id: families_ids, publish_on: ..Time.zone.today }
    end
  end
end
