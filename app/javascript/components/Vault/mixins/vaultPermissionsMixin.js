import { mapState } from 'vuex'

/* -------------------------------------------------------------------------- */
/*                          Permissions specification                         */
/* -------------------------------------------------------------------------- */
/**
 * 
 * PERMISSION SET 1: can add files, delete empty boxes, create boxes, rename:
 * this.$possible('add_boxes_to_vault', 'Vault', {ownerType: 'User', ownerId: asset.attributes.userId}) || this.$possible('add_boxes_to_vault', 'Vault', {ownerType: 'Family', ownerId: this.current_family.id})
 * 
 * NOTICE that for ability to add files/create boxes canAddBoxesToVault() should be checked with currentUser.Id
 * 
 * 
 * PERMISSION SET 2: delete/move files:
 * this.$possible('manage', 'ActiveStorage::Attachment', {userId: asset.attributes.userId, familyId: this.current_family.id})
 * 
 */
export default {
    computed: {
        ...mapState("vaults", ["selectedVaultItems"]),
        ...mapState('families', ['community']),
        ...mapState({
            userId: state => state.core.user.id
        }),

        /* ---------------------- Example of usage in component --------------------- */
        /*  
        permissionSet1() {
            return this.selectedVaultItems.every(this.canAddBoxesToVault)
        },
        permissionSet2() {
            return this.selectedVaultItems.every(item => this.isAsset(item) && this.canManage(item))
        } 
        */
    },
    methods: {
        isAsset: (item) => item.attributes.itemType == 'file',
        canManage(item) {
            return this.$possible('manage', 'ActiveStorage::Attachment', {
                userId: item?.attributes?.userId || Number(this.userId),
                familyId: this.community.id
            })
        },
        canAddBoxesToVault(item) {
            const userCan = this.$possible('add_boxes_to_vault', 'Vault', {
                ownerType: 'User',
                ownerId: item?.attributes.userId || Number(this.userId)
            })

            const familyCan = this.$possible('add_boxes_to_vault', 'Vault', {
                ownerType: 'Family',
                ownerId: this.community.id
            })

            return userCan || familyCan
        }
    }
}