<template>
  <div class="legacy-styles">
    <div class="for-form">
      <div>
        <h2 class="form-title">
          {{ $i18n.t('transfer.form.title') }}
        </h2>
        <div class="form-subtitle for-subtitle">
          {{ $i18n.t('transfer.form.subtitle') }}
        </div>
        <form class="simple_form transfer">
          <h5 class="ui-section-title">
            {{ $i18n.t('transfer.form.choose_family_to_go') }}
          </h5>
        
          <fieldset>
            <div class="row">
              <div>
                <label>
                  {{ $i18n.t('transfer.form.choose_family') }}
                </label>
                <v-select
                  v-model="family"
                  :get-option-label="option => option.attributes.name"
                  :searchable="true"
                  :taggable="true"
                  :options="families"
                  @input="onInput(family)"
                />
              </div>
              <div
                v-if="selectedId"
              >
                <label>
                  {{ $i18n.t('transfer.form.choose_member') }}
                </label>
                <v-select
                  v-model="member"
                  label="name"
                  :searchable="true"
                  :taggable="true"
                  :options="members"
                />
              </div>
              <div
                v-if="selectedId"
              >
                <label>
                  {{ $i18n.t('transfer.form.end_date') }}
                </label>
                <input
                  id="endDt"
                  v-model="endDate"
                  type="datetime-local"
                  @input="onEndDate"
                >
              </div>
              <div
                v-if="selectedId"
                class="col20 pt28"
              >
                <input
                  :disabled="!member || !endDate"
                  type="submit"
                  name="commit"
                  value="Send Transfer Request"
                  @click.prevent="onSubmit()"
                >
              </div>
            </div>
          </fieldset>
        
          <p>
            {{ $i18n.t('transfer.form.transferee_instructions') }}
          </p>
        </form>
      </div>
    </div>
  </div>
</template>

<script>
import {mapActions, mapState} from 'vuex'
import vSelect from 'vue-select'
import 'vue-select/dist/vue-select.css'
import familiesRepository from '../../repositories/families-repository'
export default {
  components: { vSelect },
  props: {
    families: {
      type: Array,
      required: true
    },
    kinships: {
      type: Array,
      required: true
    }
  },
  data () {
    return {
      family: '',
      selectedId: '',
      member: '',
      members: [],
      // startDate: '',
      endDate: '',
      timeZone: ''
    }
  },
  computed: {
    ...mapState({
      currentUser: state => state.core.user
    })
  },
  methods: {
    ...mapActions({
      failureFlashMessage: 'failureFlashMessage',
      successFlashMessage: 'successFlashMessage'
    }),
    onInput (family) {
      this.selectedId = family.id
      this.member = ''
      this.members = this.kinships.map(kinship => {
        if (kinship.attributes.family_id === this.selectedId) {
          return {
            name: kinship.attributes.name,
            userId: kinship.attributes.user_id,
            id: kinship.id
          }
        }
      })

      setTimeout(function () {
        var dtToday = new Date()
        var month = dtToday.getMonth() + 1
        var day = dtToday.getDate()
        var year = dtToday.getFullYear()
        var hour = dtToday.getHours()
        var minute = dtToday.getMinutes()
        if (minute < 10) { minute = '0' + minute.toString() }
        if (month < 10) { month = '0' + month.toString() }
        if (day < 10) { day = '0' + day.toString() }

        var today = year + '-' + month + '-' + day + 'T' + hour + ':' + minute

        // document.getElementById('startDt').min = today
        document.getElementById('endDt').min = today
      }, 500)
    },
    onEndDate () {
    //   this.flag = false
    //   if (this.endDate < this.startDate) {
    //     this.flag = true
    //     this.failureFlashMessage('Please enter valid end date.')
    //   }
    },
    async onSubmit () {
      this.timeZone = Intl.DateTimeFormat().resolvedOptions().timeZone
      let payload = {
        family_id: this.selectedId,
        new_admin_id: this.member.userId,
        end_date: this.endDate,
        time_zone: this.timeZone
      }
      try {
        await familiesRepository.ownershipDataPost(payload)
          .then(response => {
            if (response.success) {
              this.successFlashMessage(
                'Administrator Change request sent Successfully.'
              )
              this.endDate = ''
              this.member = ''
              this.flag = false
              this.selectedId = ''
              this.family = ''
            }
          })
      } catch (error) {
        this.failureFlashMessage(this.$i18n.t('requests.failure'))
      }
    }
  }
}
</script>

<style scoped>
.column {
float: left;
width: 40%;
padding-right: 7px;
height: 60px;
}
.col20 {
float: left;
width: 20%;
padding-right: 7px;
height: 60px;
margin-top: 27px;
}
.col50 {
width: 50% !important;
}
.row:after {
content: "";
display: table;
clear: both;
}
.for-form{
margin-left: 35px;
margin-right: 35px;
}
.for-subtitle{
margin-top: -35px;;
}
.pt22{
padding-top: 22px;
}
.pt28{
padding-top: 28px;
}
</style>
