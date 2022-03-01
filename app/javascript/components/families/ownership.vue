<template>
  <div class="legacy-styles">
    <div class="for-form">
      <div>
        <h2 class="form-title">
          Change Administrator
        </h2>
        <div class="form-subtitle for-subtitle">
          Transfer Account Ownership from You to Different Community Member
        </div>
        <form class="simple_form transfer">
          <h5 class="ui-section-title">
            Choose Community you want to change
          </h5>
        
          <fieldset>
            <div class="row">
              <div>
                <label>Choose Community</label>
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
                <label>Choose Member</label>
                <v-select
                  v-model="member"
                  label="name"
                  :searchable="true"
                  :taggable="true"
                  :options="members"
                />
              </div>
              <!-- <div
                v-if="selectedId"
                class="column pt22"
              >
                <label>Start Date</label>
                <input
                  id="startDt"
                  v-model="startDate"
                  type="datetime-local"
                >
              </div> -->
              <div
                v-if="selectedId"
              >
                <label>End Date</label>
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
            An email will be sent to selected Community Member asking them to
            accept or decline Community Administrator responsibilities and
            ownership of this Community Account.
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
  data () {
    return {
      family: '',
      families: [],
      kinships: '',
      candidates: '',
      selectedId: '',
      members: [],
      member: '',
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
  async created () {
    try {
      await familiesRepository.ownershipData()
        .then(response => {
          this.families = response.data.filter(i =>
            i.attributes.connector_id.toString() ===
              this.currentUser.id.toString()
          )
          this.kinships = response.included.filter(i => i.type === 'kinship')
          this.candidates = response.included.filter(i => i.type === 'user')
        })
    } catch (error) {
      console.log(error)
    }
  },
  methods: {
    ...mapActions({
      failureFlashMessage: 'failureFlashMessage',
      successFlashMessage: 'successFlashMessage'
    }),
    onInput (value) {
      this.selectedId = value.id
      this.member = ''
      this.members = []

      let familyIds = []
      this.kinships.map(k => {
        if (k.attributes.family_id === this.selectedId) {
          familyIds.push(k.attributes.user_id.toString())
        }
      })

      this.candidates.map(c => {
        if (familyIds.includes(c.id) && c.id !== this.currentUser.id) {
          this.members.push({
            name: c.attributes.name,
            id: c.id
          })
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
        new_admin_id: this.member.id,
        // startDate: this.startDate,
        endDate: this.endDate,
        timeZone: this.timeZone
      }
      // if (!this.flag) {
      try {
        await familiesRepository.ownershipDataPost(payload)
          .then(response => {
            if (response.success) {
              this.successFlashMessage(
                'Administrator Change request sent Successfully.'
              )
              // this.startDate = ''
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
      // } else {
      //   this.failureFlashMessage('Please enter valid end date.')
      // }
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
