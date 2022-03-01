<template>
  <div class="subheader">
    <ul class="filter-container submenu">
      <li class="section family-filters page-filters my-life-submenu-container">
        <nav
          v-if="kinship"
          class="my-life-submenu"
        >
          <div
            class="pull-left"
          >
            <family-selector
              :default-id="chosenFamilyId"
              :only-show-concrete-communities="$route.name !== 'myStories'"
              @family-changed="familyChanged($event)"
            />
            <div class="back-link-new">
              <a :href="`/communities/${family.id}/kinships`">
                <span class="icon-arrow" />
                <span class="link-text">
                  {{ $i18n.t('users.kinships.profile.back_link') }}
                </span>
              </a>
            </div>
          </div>
          <div
            class="story-tabs for-tabs"
            :class="{'for-profile-tabs': $route.name === 'myProfile'}"
          >
            <router-link
              v-if="this.$route.params.id === undefined"
              class="tab"
              :to="{ name: 'myProfile' }"
              :title="$i18n.t('mylives.submenu.profile_title')"
            >
              <span>{{ $i18n.t('mylives.submenu.profile') }}</span>
            </router-link>
            <router-link
              v-else
              class="tab"
              :to="{ name: 'member', params: { id: kinship.id } }"
              :title="$i18n.t('mylives.submenu.profile_title')"
            >
              <span>{{ $i18n.t('mylives.submenu.profile') }}</span>
            </router-link>
            <router-link
              v-if="this.$route.params.id === undefined"
              class="tab"
              :to="{ name: 'myStories' }"
              :title="$i18n.t('mylives.submenu.stories_title')"
            >
              <span>{{ $i18n.t('mylives.submenu.stories') }}</span>
            </router-link>
            <router-link
              v-else-if="user"
              class="tab"
              :to="{ name: 'kinStories', params: { kinshipId: kinship.id } }"
              :title="$i18n.t('mylives.submenu.stories_title')"
            >
              <span>{{ $i18n.t('mylives.submenu.stories') }}</span>
            </router-link>
            <router-link
              v-if="$route.params.id === undefined"
              class="tab"
              :to="{ name: 'showVault', params: { id: vaultId } }"
              :title="$i18n.t('mylives.submenu.my_store_title')"
            >
              <span>{{ $i18n.t('mylives.submenu.my_store') }}</span>
            </router-link>
          </div>
          <div v-if="this.$route.params.kinshipId !== undefined">
            <button
              class="remove-btn"
              @click="removeFromCommunity"
            >
              <i class="icon icon-delete" />
              {{ $i18n.t('families.remove_member') }}
            </button>
          </div>
          <div
            v-if="$route.name === 'myStories'"
            class="view-btn"
          >
            <a
              class="story-action display-btn"
              :class="{'active':checkViewType}"
              @click="selectView('list')"
            >
              <i class="fa fa-list fa-fw" /> List
            </a>

            <a
              class="story-action display-btn"
              :class="{'active':!checkViewType}"
              @click="selectView('grid')"
            >
              <i class="fa fa-th fa-fw" /> Grid
            </a>
          </div>
        </nav>
      </li>
    </ul>
  </div>
</template>

<script>
import {mapActions, mapState} from 'vuex'
import FamilySelector from '../Layout/family-selector'
import { AttachmentsRepository, KinshipsRepository } from '../../repositories'

export default {
  components: { FamilySelector },
  props: {
    kinship: {
      type: Object,
      default: null
    },
    editMode: {
      type: Boolean,
      default: false
    },
    showEdit: {
      type: Boolean,
      default: true
    },
    chosenFamilyId: {
      type: [String, Number],
      required: true
    }
  },
  data () {
    return {
      vaultId: '',
      checkViewType: false
    }
  },
  computed: {
    ...mapState({
      currentUser: state => state.core.user
    }),
    user () {
      return this.kinship.included.find(k => k.type === 'user')
    },
    family () {
      return this.kinship.included.find(k => k.type === 'family')
    }
  },
  mounted () {
    if (this.$route.params.id === undefined) {
      try {
        AttachmentsRepository.getMyVault()
          .then(response => {
            this.vaultId = response.data.id
          })
      } catch (error) {
        console.log(error)
      }
    }
  },
  methods: {
    ...mapActions({
      findFamily: 'families/findRecord',
      deleteMember: 'kinships/deleteKinship',
      successFlashMessage: 'successFlashMessage',
      failureFlashMessage: 'failureFlashMessage'
    }),
    selectView (value) {
      if (value === 'grid') {
        this.checkViewType = false
        this.$emit('onChangeViewtype', this.checkViewType)
      } else {
        this.checkViewType = true
        this.$emit('onChangeViewtype', this.checkViewType)
      }
    },
    async familyChanged (familyID) {
      this.$emit('family-filter-changed', familyID)

      let tempAry = this.currentUser.relationships.families.data
      const found = tempAry.find(element => element.id === familyID)

      if (this.$route.name === 'member') {
        if (!found) {
          this.$router.push('/communities/' + familyID + '/edit')
        } else {
          let payload = {
            family_id: familyID,
            user_id: this.currentUser.id
          }
          try {
            await KinshipsRepository.getKinshipID(payload)
              .then(response => {
                let id = response.data.id
                this.$router.push('/kinships/' + id + '/mylife/profile')
              })
          } catch (error) {
            console.log(error)
          }
        }
      }
    },
    async removeFromCommunity () {
      await this.deleteMember(this.$route.params.id)
      this.$router.go(-1)
    }
  }
}
</script>

<style lang="scss" scoped>

  .for-tabs{
    left: calc(-50% + 250px);
  }
  .for-profile-tabs{
    left: calc(-40% - 5%) !important;
  }

  .display-btn{
    color: #8B78FE !important;
    background: #fff;
    border-radius: 20px;
    border: 1px solid #8B78FE;
    padding: 9px;
    line-height: 32px !important;
    margin: 3px;
    cursor: pointer;
  }

  .remove-btn {
    color: #8B78FE;
    background: #fff;
    border-radius: 20px;
    border: 1px solid #8B78FE;
    padding: 6px 10px 6px 10px;
    line-height: 20px;
    &:hover {
      background: #ff6a6a;
      border-color: #ff1818;
      color: #fff;
    }
    .icon {
      line-height: 20px;
      width: 20px;
    }
  }

  a.story-action.active{
    background: #8B78FE !important;
    color: #FFF !important;
  }

  .view-btn{
    margin-top:5px;
    text-align:end;
  }
</style>
