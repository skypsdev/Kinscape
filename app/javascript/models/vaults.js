
class Vault {
  constructor(vault = {}) {
    this.id = vault.id || null
    this.ownerType = vault.attributes?.ownerType || null
    this.ownerId = vault.attributes?.ownerId || null
    this.name = vault.attributes?.name || null
    this.avatarUrl = vault.attributes?.avatarUrl || null
    this.items = vault.items || []
    this.box = vault?.box || {}
  }
}

export {
  Vault
}
