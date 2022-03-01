import 'cookieconsent'
import 'cookieconsent/build/cookieconsent.min.css'

window.addEventListener('load', function () {
  window.cookieconsent.initialise({
    palette: {
      popup: {
        background: '#8B78FE',
        text: '#FFFFFF'
      },
      button: {
        background: '#EE5D2E',
        text: '#FFFFFF'
      }
    },
    theme: 'classic',
    content: {
      href: '/pages/privacy'
    }
  })
})
