
import mitt from 'mitt'
import Vue from 'vue'
const emitter = mitt();

export default () => {
      Vue.prototype.$eventBus = emitter;
}
