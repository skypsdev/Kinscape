import { mapState } from 'vuex'
export default {
    computed: {
        ...mapState('core', ['user']),
        ...mapState('families', ['community']),
        insideMyVaultView() {
            return ["MyVault", "MyBoxVault"].includes(this.$route.name)
        },
        insideBoxView() {
            return ["MyBoxVault", "CommunityBoxVault"].includes(this.$route.name)
        },
        vaultId() {
            if (this.insideMyVaultView) {
                return this.user.vault.id
            } else {
                return this.community.vaultId
            }
        }
    }
}