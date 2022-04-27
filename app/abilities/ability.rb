class Ability
  ALL_ABILITIES = Abilities.constants
  ALL_ABILITIES.each { |module_name| include Abilities.const_get(module_name) }

  include CanCan::Ability

  # !!! manage is above all other actions !!!
  # eg
  # can :collaborate, Publication, { share_type: 'community' }
  # can :manage, Publication, { story: { user_id: current_user.id } }
  # publication = { user_id: current_user.id, share_type: 'private' }
  # current_user.can?(:collaborate, publication) => true (share_type)

  def initialize(user, casl: false, showcase: false)
    @user = showcase ? User.find_by(email: Showcase::USER_EMAIL) : user
    @families = showcase ? Family.where(showcase: true) : user.families
    @casl = casl
    @showcase = showcase

    send("#{role}_abilities")
  end

  def to_list
    rules.map do |rule|
      object = { action: rule.actions, subject: rule.subjects.map { |s| s.is_a?(Symbol) ? s : s.name } }
      object[:conditions] = serialize_conditions(nil, rule.conditions).reduce(:merge) if rule.conditions.present?
      object[:inverted] = true unless rule.base_behavior
      object
    end
  end

  private

  attr_reader :user, :families, :casl, :showcase

  def role
    return 'showcase' if showcase
    return 'super_admin' if user.admin

    'default'
  end

  def default_abilities
    ALL_ABILITIES.each { |module_name| send("default_#{module_name.to_s.underscore}") }
  end

  def super_admin_abilities
    default_abilities
    ALL_ABILITIES.each { |module_name| send("super_admin_#{module_name.to_s.underscore}") }
  end

  def showcase_abilities
    ALL_ABILITIES.each { |module_name| send("showcase_#{module_name.to_s.underscore}") }
  end

  def families_ids
    @families_ids ||= families.map(&:id)
  end

  def all_families_ids
    @all_families_ids ||= families_ids + following_families_ids + followers_families_ids
  end

  def following_families_ids
    @following_families_ids ||= user.following_families.map(&:id)
  end

  def followers_families_ids
    @followers_families_ids ||= user.followers_families.map(&:id)
  end

  # def owned_families_ids
  #   @owned_families_ids ||= families.find_all { |family| user.role_for(family) == 'admin' }.map(&:id)
  # end

  def admin_families_ids
    @admin_families_ids ||= families.find_all { |family| user.role_for(family).in?(%w[admin co_admin]) }.map(&:id)
  end

  def guested_families_ids
    @guested_families_ids ||= families.find_all { |family| user.role_for(family) == 'guest' }.map(&:id)
  end

  def except_guested_ids
    @except_guested_ids ||= families.find_all { |family| user.role_for(family) != 'guest' }.map(&:id)
  end

  # def user_access_type
  #   @user_access_type ||= user.active_subscription.presence || user.ability_all ? :manage : [:read, :destroy]
  # end

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
