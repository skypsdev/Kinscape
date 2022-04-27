import Repository from './repository'

const resource = '/requests'
const messages = '/messages'
export default {
  sendMessage (payload) {
    return Repository.post(resource, payload)
  },
  getRecipients () {
    return Repository.get(`${messages}/recipients`)
  }
}
