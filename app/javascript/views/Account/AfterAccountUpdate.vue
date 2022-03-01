<template>
  <div class="legacy-styles">
    <div class="families-container page-container">
    <h2 class="main-title">
      What would you like to do now?
    </h2>
    <section class="family-members page-blocks-holder">
      <div class="families blocks">
        <div class="family block">
          <div class="cover-box">
            <div class="cover-bg center-block">
              <ul style="list-style-type:disc;">
                <li>
                  Add or Edit a Community
                </li>
                <li>
                  Email invitations to join a Community
                </li>
                <li>
                  Add Members without email addresses.
                </li>
                <li>
                  Read or Edit a Community Profile
                </li>
              </ul>
              <a

                href="https://intercom.help/kinscape/en/collections/41108-familyscape"
                target="_blank"
              >
                <b style="color:#8B78FE;">For more information click here</b>
              </a>
            </div>

            <div class="title">
              <div class="title-wrapper">
                <p class="for-text-center">
                  <a
                    href="/communities"
                    style="margin-left: -26px;"
                    class="make-button"
                  >
                    Communities
                  </a>
                </p>
              </div>
            </div>
          </div>
        </div>

        <div class="family block">
          <div
            class="cover-box"
          >
            <div class="cover-bg center-block">
              <ul style="list-style-type:disc;">
                <li>
                  Start or Edit a Story
                </li>
                <li>
                  Share a Story or keep it Private
                </li>
                <li>
                  Add images, videos, files to a Story
                </li>
                <li>
                  Read, Appreciate, Comment on other Members' Stories
                </li>
              </ul>
              <a
                href="https://intercom.help/kinscape/en/collections/41099-storyscape"
                target="_blank"
              >
                <b style="color:#8B78FE;">For more information click here</b>
              </a>
            </div>
            <div class="title">
              <div class="title-wrapper">
                <p class="for-text-center">
                  <a
                    href="/stories"
                    style="margin-left: -5px;"
                    class="make-button"
                  >
                    Stories
                  </a>
                </p>
              </div>
            </div>
          </div>
        </div>

        <div class="family block">
          <div
            class="cover-box"
          >
            <div class="cover-bg center-block">
              <ul style="list-style-type:disc;">
                <li>
                  Write or Edit your Profile
                </li>
                <li>
                  See your Private Stories; Diary, Objectives, etc.
                </li>
                <li>
                  See Stories Shared with other Members
                </li>
              </ul>
              <a
                href="https://intercom.help/kinscape/en/collections/41179-my-life"
                target="_blank"
              >
                <b style="color:#8B78FE;">For more information click here</b>
              </a>
            </div>
            <div class="title">
              <div class="title-wrapper">
                <p class="for-text-center">
                  <a
                    href="/mylife/profile"
                    class="make-button"
                  >
                    My Life
                  </a>
                </p>
              </div>
            </div>
          </div>
        </div>

        <!-- <li class="family block">
          <div
            class="cover-box"
          >
            <div class="cover-bg center-block">
              <ul style="list-style-type:disc;">
                <li>
                  Set up Boxes for back up Content
                </li>
                <li>
                  Load images, videos, etc. for others to see or use
                </li>
                <li>
                  See or use Content in other Members' Boxes
                </li>
              </ul>
              <a
                href="https://intercom.help/kinscape/en/collections/41123-vault"
                target="_blank"
              >
                <b style="color:#8B78FE;">For more information click here</b>
              </a>
            </div>
            <div class="title">
              <div class="title-wrapper">
                <p class="for-text-center">
                  <a href="/vaults">
                    <b style="color:#8B78FE;">Vault</b>
                  </a>
                </p>
              </div>
            </div>
          </div>
        </li> -->
      </div>
    </section>
  </div>
  </div>
</template>

<script>
import { mapActions } from 'vuex'
export default {
  mounted () {
    let query = Object.assign({}, this.$route.query)
    let successMessage
    if (Object.keys(query).length !== 0) {
      if (query.success === 'already_accepted') {
        successMessage = this.$i18n.t('invitations.flash.success.already_accepted')
      } else if (query.success === 'accepted') {
        successMessage = this.$i18n.t('invitations.flash.success.accepted')
      }
    }
    if (successMessage) {
      delete query.success
      this.$router.replace({ query })
      this.setSnackbar({messages: [successMessage]})
    }
  },
  methods: {
    ...mapActions({
      setSnackbar: 'layout/setSnackbar'
    })
  }
}
</script>

<style scoped>

.for-text-center {
  margin-left: 127px;
  font-size: 22px;
  margin-top: 10px;
}

.center-block{
  font-size: larger;
  color: black;
  margin: 50px 50px !important;
  background-color: white !important;
}

.main-title{
  margin-top: -100px;
  margin-left: 525px;
}

.block{
  width: 31% !important;
}

.blocks .block .cover:before{
  box-shadow: inset 0 0 0 2px rgba(0, 0, 0, 0.2) !important;
  border-color: purple !important;
}

.cover-box{
    position: absolute !important;
    top: 0px !important;
    right: 0px !important;
    bottom: 0px !important;
    left: 0px !important;
    box-shadow: inset 0 0 0 1px rgba(0, 0, 0, 0.2) !important;
    z-index: 3 !important;
}

.blocks .block {
  padding-top: 20% !important;
}

.make-button{
    border-radius: 3px;
    border: 1px solid #8B78FE;
    font-weight: 550;
    letter-spacing: 1px;
    cursor: pointer;
    padding: 0.4em;
    color: #8B78FE;
    background: #fff;
}

.make-button:hover{
  background: #8B78FE;
  color: white !important;
}

</style>
