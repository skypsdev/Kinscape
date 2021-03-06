import { Community } from "./communities";

class Member {
    constructor(member = {}) {
        this.id = member.id || null
        this.userId = member.attributes?.userId || null
        this.role = member.attributes?.role || ''
        this.familyId = member.attributes?.familyId || ''
        this.name = member.attributes?.name || ''
        this.nickname = member.attributes?.nickname || ''
        this.email = member.attributes?.email || ''
        this.avatarUrl = member.attributes?.avatarUrl || ''
        this.deathDate = member.attributes?.deathDate || ''
        this.createdAt = member.attributes?.createdAt || ''
        this.acceptedAt = member.attributes?.acceptedAt || ''
        this.invitedBy = member.attributes?.invitedBy || ''
        this.senderName = member.attributes?.senderName || ''
        this.accessType = member.attributes?.accessType || 'default'

        this.isConnectedByCurrentUser = member.attributes?.isConnectedByCurrentUser || false
        this.isCurrentUserConnector = member.attributes?.isCurrentUserConnector || false

        this.profile = member.attributes?.profileAttrs || {}
        this.content = {
            links: member.attributes?.links || [],
            chapters: []
        }
        this.community = new Community(member.included?.find(i => i.type === 'family')) || {}
        this.user = member.included?.find(i => i.type === 'user') || {}
        this.isLoading = false
        this.isChanged = false
    }
}

export {
    Member
}
