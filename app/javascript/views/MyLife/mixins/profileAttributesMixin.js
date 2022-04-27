import { cloneDeep as _cloneDeep } from 'lodash'
import { mapActions } from 'vuex'

import ProfileContactDetails from '@/components/Profiles/ProfileContactDetails.vue'

export default {
    components: {
        ProfileContactDetails
    },
    data() {
        return {
            profileAttributes: null
        }
    },
    methods: {
        ...mapActions("members", ["getMyProfileByCommunityId", "clearMember"]),
        async getMyProfile(communityId) {
            const profile = await this.getMyProfileByCommunityId({id:communityId, params:this.getShowcaseOptions()})
            this.profileAttributes = _cloneDeep(profile?.attributes?.profile_attrs)
        },
        hasValidProfileValues(attributes) {
            return Object.values(attributes).filter(val => val !== '').length
        },
        getShowcaseOptions() {
            const result = {}
            if (localStorage.getItem('tour')) {
              result.showcase = true
            }
      
            return result
        },
    }
}