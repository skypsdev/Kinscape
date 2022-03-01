class Community {
    constructor(community = {}) {
        this.id = community.id || null
        this.name = community.attributes?.name || ''
        this.description = community.attributes?.description || ''
        this.motto = community.attributes?.motto || ''
        this.type = community.attributes?.familyType || ''
        this.vaultId = community.attributes?.vaultId || null

        this.content = {
            cover: community.attributes?.coverUrl || null,
            links: community.attributes?.links || [],
            chapters: []
        }

        this.admin = {
            avatarUrl: community.attributes?.adminAvatarUrl || null,
            name: community.attributes?.connectorName || '',
            id: community.attributes?.connectorId || null,
        }

        this.isAdmin = community.attributes?.isConnectedByCurrentUser

        this.coverUrl = community.attributes?.coverUrl

        this.isChanged = false

        this.members = community.relationships?.kinships?.data || []
        this.usersIds = community.attributes?.usersIds || []
    }
}

export {
    Community
}
