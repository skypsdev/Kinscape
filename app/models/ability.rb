class Ability
  include CanCan::Ability
  # manage = [:read, :create, :update, :destroy]

  # this file is in continues development, that why its such a mess
  # with every feature there are more and more rules, which make previous chic irrelevant
  # it's still waiting for a final version where abilities will be more readable and sorted in some groups

  def initialize(user, casl: false)
    @user = user
    families = @user.families
    param = casl ? :uid : :id
    @owned_families_ids = families.find_all { |family| user.role_for(family) == 'admin' }.map(&param)
    @guested_families_ids = families.find_all { |family| user.role_for(family) == 'guest' }.map(&param)
    @families_ids = families.map(&param)
    @user_access_type = @user.active_subscription.presence || @user.ability_all ? :manage : [:read, :destroy]
    # @family_access_type = @family&.active_subscription.presence || @family&.ability_all ? :manage : [:read, :destroy]

    send("#{role}_abilities")
  end

  # rubocop:disable Metrics/AbcSize
  def default_abilities
    if families_ids.present?
      can :read, Story, { publications: { family_id: families_ids, publish_on: ..Time.zone.today } }
      can :read, Story, { publications: { family_id: families_ids, publish_on: nil } }
      can :read, Kinship, { family_id: families_ids }
      can :read, Publication, { family_id: families_ids, publish_on: nil }
      can :read, Publication, { family_id: families_ids, publish_on: ..Time.zone.today }
      can :create, Comment, { commentable: { family_id: families_ids } }
      can :create, Appreciation, { commentable: { family_id: families_ids } }
      can :add_boxes_to_vault, Vault, { owner_type: 'Family', owner_id: families_ids - guested_families_ids }
      can :read, Vault, { owner_type: 'Family', owner_id: families_ids }
      can :read, Box, { vault: { owner_type: 'Family', owner_id: guested_families_ids } }
      can :manage, Box, { vault: { owner_type: 'Family', owner_id: families_ids - guested_families_ids } }
      can :collaborate, Publication, { share_type: 'community', family_id: families_ids - guested_families_ids }
    end

    if owned_families_ids.present?
      can :manage, Kinship, { family_id: owned_families_ids, user_id: nil } # Offline Member
      can [:destroy, :update], Kinship, { family_id: owned_families_ids }
      can :manage, Family, { id: owned_families_ids }
      can :manage, Vault, { owner_type: 'Family', owner_id: owned_families_ids }
      can :manage, ActiveStorage::Attachment, { family_id: owned_families_ids }
    end

    can [:read, :update], Invitation, { recipient_id: nil }
    # TODO: remove it from CASL - emails leak
    cannot [:read, :update], Invitation, { email: User.where.not(id: user.id).pluck(:email) }
    cannot [:read, :update], Invitation, { sender_id: user.id }

    can [:read, :update], Invitation, { recipient_id: nil }
    # TODO: remove it from CASL - emails leak
    cannot [:read, :update], Invitation, { email: User.where.not(id: user.id).pluck(:email) }
    cannot [:read, :update], Invitation, { sender_id: user.id }

    can :create, Family
    can :read, Family, { kinships: { user_id: user.id } }
    can :manage, Comment, { user_id: user.id }
    can :destroy, Appreciation, { user_id: user.id }
    can :manage, User, { id: user.id }
    can :manage, Kinship, { user_id: user.id }
    cannot :destroy, Kinship, { role: :admin }
    can :manage, ActiveStorage::Attachment, { user_id: user.id }
    can :manage, Box, { vault: { owner_type: 'User', owner_id: user.id } }
    can user_access_type, [Story, MediaFile], { user_id: user.id }
    can user_access_type, Vault, { owner_type: 'User', owner_id: user.id }
    can :manage, Publication, { story: { user_id: user.id } }
    can :manage, Invitation, { recipient_id: user.id }
    can :manage, Invitation, { email: user.email }
    can :destroy, Invitation, { family_id: owned_families_ids }
    can [:update, :destroy], Section, { author_id: user.id }
    can :add_boxes_to_vault, Vault, { owner_type: 'User', owner_id: user.id }
  end
  # rubocop:enable Metrics/AbcSize

  def super_admin_abilities
    default_abilities

    can :manage, ActiveAdmin::Page
    can :manage, User
    can :manage, Kinship
    can :manage, Story, { publications: { family_id: families_ids, publish_on: nil } }
    can :manage, Story, { publications: { family_id: families_ids, publish_on: ..Time.zone.today } }
    can :manage, Section
  end

  def showcase_abilities
    can :read, Story, { publications: { family_id: families_ids, publish_on: ..Time.zone.today } }
    can :read, Story, { publications: { family_id: families_ids, publish_on: nil } }
    can :read, Publication, { family_id: families_ids, publish_on: nil }
    can :read, Publication, { family_id: families_ids, publish_on: ..Time.zone.today }
    can :read, Family, { kinships: { user_id: user.id } }
    can :read, User, { id: user.id }
    can :read, Box, { vault: { owner_type: 'User', owner_id: user.id } }
    can :read, [Story, MediaFile, Box, Kinship], { user_id: user.id }
    can :read, Vault, { owner_type: 'User', owner_id: user.id }
    can :read, Vault, { owner_type: 'Family', owner_id: families_ids }
  end

  def to_list
    rules.map do |rule|
      object = { action: rule.actions, subject: rule.subjects.map { |s| s.is_a?(Symbol) ? s : s.name } }
      object[:conditions] = serialize_conditions(nil, rule.conditions).reduce(:merge) if rule.conditions.present?
      object
    end
  end

  private

  attr_reader :user, :owned_families_ids, :user_access_type, :families_ids, :guested_families_ids

  def role
    return 'showcase' if ENV.key? 'SHOWCASE_USER_ID'
    return 'super_admin' if user.admin

    'default'
  end

  # here is example conversion of serialize_conditions method
  # before: {:publications=>{:family_id=>[1, "2y7gIGpa6Ef"], :publish_on=>..Fri, 05 Nov 2021}}
  # after: {"publications.family_id"=>{:$in=>[1, "2y7gIGpa6Ef"]}, "publications.publish_on"=>{:$lte=>Fri, 05 Nov 2021}}

  def serialize_conditions(master_key, hash)
    hash.map do |key, value|
      new_key = master_key ? "#{master_key}.#{key}" : key
      case value
      when Hash
        serialize_conditions(new_key, value).reduce(:merge)
      when Array
        { new_key => { :$in => value } }
      when Range
        { new_key => { :$lte => value.last } }
      else
        { new_key => value }
      end
    end
  end
end
