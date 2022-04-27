import { mapState } from 'vuex'

/* -------------------------------------------------------------------------- */
/*                          Permissions specification                         */
/* -------------------------------------------------------------------------- */
/**
 * 
 * PERMISSION SET 1: can add files, delete empty boxes, create boxes, rename:
 *  this.$possible('add_boxes_to_vault', 'Vault', {
                ownerType: vault.ownerType,
                ownerId: vault.ownerId
            })
 * 
 * 
 * 
 * PERMISSION SET 2: delete/move files:
 * this.$possible('manage', 'ActiveStorage::Attachment', {
            userId: item.attributes.userId,
            familyId: item.attributes.familyId
        })
 * 
 */
export default {
    computed: {
        ...mapState("vaults", ["selectedVaultItems"]),
        ...mapState('families', ['community'])

        /* ---------------------- Example of usage in component --------------------- */
        /*  
        permissionSet1() {
            return this.canAddBoxesToVault(vault)
        },
        permissionSet2() {
            return this.selectedVaultItems.every(item => this.isAsset(item) && this.canManageAsset(item))
        } 
        */
    },
    methods: {
        isAsset: (item) => item.attributes.itemType == 'file',
        isBox: (item) => item.attributes.itemType == 'box',
        canManageAsset(item) {
            return this.$possible('manage', 'ActiveStorage::Attachment', {
                userId: item.attributes.userId,
                familyId: item.attributes.familyId
            })
        },
        canAddBoxesToVault(vault) {
            return this.$possible('add_boxes_to_vault', 'Vault', {
                ownerType: vault.ownerType,
                ownerId: vault.ownerId
            })
        }
    }
}
