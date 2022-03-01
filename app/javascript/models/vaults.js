
class Vault {
  constructor(vault = {}) {
    this.id = vault.id || null
    this.attributes = vault?.attributes || {}
    this.items = vault.items || []
  }
}

export {
  Vault
}
