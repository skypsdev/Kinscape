class User {
  constructor(user = {}) {
    this.id = user.id || null
    this.avatar = user.attributes?.avatarUrl || null
    this.name = user.attributes?.name || null
    this.firstName = user.attributes?.firstName || null
    this.lastName = user.attributes?.lastName || null
    this.birthDate = user.attributes?.birthDate || null
    this.email = user.attributes?.email || null
    this.guest = user.attributes?.guest || false
    this.phone = user.attributes?.phone || null
    this.vault = {
      id: user.attributes?.vaultId || null
    }
    this.isAdmin = user.attributes?.admin || false
    this.familyId = user.attributes?.personalFamilyId || null
    this.privateFamilyId = user.attributes?.privateFamilyId || null
    this.personalPrivateFamilies = user.attributes?.personalPrivateFamilies || null
    // TODO Legacy Remove
    this.location = user.attributes?.location || null
    this.registrationMethod = user.attributes?.registrationMethod || 'direct'
    this.onboarding = user.attributes?.onboarding || { tooltip: {} }
    this.onboarding.tooltip = this.onboarding.tooltip || {}
  }
}

export {
  User
}
