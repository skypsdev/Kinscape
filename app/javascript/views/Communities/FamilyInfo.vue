<template>
  <div class="legacy-styles">
    <div class="main-div">
      <SubHeader />

      <div class="account__actions">
        <div class="account__actions-title">
          {{ $i18n.t('account.actions.title') }}
        </div>
      </div>

      <OwnerShip
        :families="allFamilies"
        :kinships="kinships"
      />

<!--      <div class="download_content_section">-->
<!--        <h2 class="form-title">-->
<!--          Download Content-->
<!--        </h2>-->
<!--        <div-->
<!--          v-if="temp"-->
<!--        >-->
<!--          Previously Generated Zip File :-->
<!--          <a-->
<!--            :href="fileURL"-->
<!--            style="color:#8B78FE;"-->
<!--          ><b>{{ fileName }}</b></a>-->
<!--        </div>-->

<!--        <div-->
<!--          v-show="showDownloadDiv"-->
<!--          class="mt15"-->
<!--        >-->
<!--          <h5 class="ui-section-title">-->
<!--            Choose Community you want to download-->
<!--          </h5>-->
<!--          <div>-->
<!--            <fieldset>-->
<!--              <div-->
<!--                v-if="allFamilies && allFamilies.length>0"-->
<!--              >-->
<!--                <v-select-->
<!--                  v-model="family"-->
<!--                  :get-option-label="option => option.attributes.name"-->
<!--                  :searchable="true"-->
<!--                  :taggable="true"-->
<!--                  :options="allFamilies"-->
<!--                />-->
<!--              </div>-->
<!--              <div class="col2">-->
<!--                <input-->
<!--                  style="margin-top:-1px"-->
<!--                  :disabled="!family"-->
<!--                  type="submit"-->
<!--                  name="commit"-->
<!--                  value="Download"-->
<!--                  @click="onSubmit()"-->
<!--                >-->
<!--              </div>-->
<!--            </fieldset>-->
<!--          </div>-->
<!--        </div>-->

<!--        <div-->
<!--          v-show="!showDownloadDiv"-->
<!--          id="progress-bar"-->
<!--        >-->
<!--          <div />-->
<!--        </div>-->
<!--      </div>-->

<!--      <div class="account__families familyList-div">-->
<!--        <div class="account__families-header">-->
<!--          Your Communities-->
<!--        </div>-->
<!--        <ListForAccount-->
<!--          :family-list="allFamilies"-->
<!--        />-->
<!--      </div>-->

      <!-- <div class="account__actions-item">
        Storage space used by Your Communities:&nbsp;<b>{{ size }}</b>
      </div> -->
    </div>
  </div>
</template>
<script>
import { mapActions } from 'vuex'
import OwnerShip from '../../components/families/ownership'
import familiesRepository from '../../repositories/families-repository'
import SubHeader from '../../components/families/sub-header'

export default {
  components: {
    OwnerShip,
    SubHeader
  },
  data () {
    return {
      size: '',
      family: '',
      showDownloadDiv: true,
      fileURL: '',
      fileName: '',
      temp: false,
      allFamilies: [],
      kinships: []
    }
  },
  created () {
    try {
      familiesRepository.ownershipData()
        .then(response => {
          this.allFamilies = response.data
          this.kinships = response.included.filter(i => i.type === 'kinship')
        })
    } catch (error) {
      console.log(error)
    }
  },
  methods: {
    ...mapActions({
      successFlashMessage: 'successFlashMessage',
      failureFlashMessage: 'failureFlashMessage'
    }),
    onSubmit () {
      let payload = {
        id: this.family.id
      }
      let msg = 'Download processing and will complete shortly.'
      let failMsg = 'There is no Content to download in selected Community.'
      try {
        this.successFlashMessage(msg)
        familiesRepository.downloadContent(payload)
          .then(response => {
            if (!response.success) {
              this.failureFlashMessage(failMsg)
            }
          })
      } catch (error) {
        console.log(error)
      }
    }
  }
}
</script>
<style scoped lang="scss">
.main-div {
    margin-left: 340px;
    margin-right: 340px;
}

.familyList-div {
    margin-top: 60px;
}

.download_content_section {
    margin-top: 60px;
    margin-left: 35px;
    margin-right: 35px;
}

.mt15 {
  margin-top: 15px;
}

.col2 {
  float: left;
  width: 50%;
  padding-right: 7px;
  height: 60px;
}
.row:after {
  content: "";
  display: table;
  clear: both;
}
</style>
