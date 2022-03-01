import Vue from 'vue'
import Vuetify from 'vuetify/lib'
Vue.use(Vuetify)

const opts = {
  theme: {
    themes: {
      light: {
        primary: '#E75739',
        primary_dark: '#CD4F2D',
        primary_light: '#F78161',
        primary_lighter: '#F9A189',
        primary_lightest: '#FCD0C4',
        secondary: '#8B78FE',
        secondary_darker: '#2A244C',
        secondary_dark: '#534898',
        secondary_light: '#A293FE',
        secondary_lighter: '#C5BCFF',
        secondary_lightest: '#E8E4FF',
        lightest_purple: '#F9F8FF',
        dark_white: '#F7F7F7',
        tertiary: '#4B4B4B',
        light_grey: '#E7E7E7',
        grey: '#939393',
        medium_grey: '#C4C4C4',
        title: '#1E1E1E',
        text: '#666666',
        disabled: '#E6E6E6',
        success: '#18A957',
        warning: '#FFBB38',
        error: '#DF1642',
        required: '#E95631'
      }
    }
  },
  icons: {
    iconfont: 'mdi' // 'mdi' || 'mdiSvg' || 'md' || 'fa' || 'fa4' || 'faSvg'
  }
}

export default new Vuetify(opts)
