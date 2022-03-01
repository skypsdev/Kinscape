import Vue from "vue";
import VueMoment from "vue-moment";

/**
 * Returns desired deep key-value in vue template (we cannot use here ?. sign because of vue 2 limitations)
 * for example:
 * 1.  $$({a: {b: {c:null } } },'b','c' ) => return null
 * 2. $$({a: {b: {c:null } } },'b','g' ) => return ''  - empty string because no key for such nested data
 * @param {Object} obj object to get keys deeply
 * @param  {...any} rest coma separated list of keys to get
 * @returns desired deep key-value or empty string
 */
const optionalChaining = (obj, ...rest) => {
  let tmp = obj;
  for (let key in rest) {
    let name = rest[key];
    tmp = tmp?.[name];
  }
  return tmp !== undefined ? tmp : "";
};
export default () => {
  Vue.prototype.$$ = optionalChaining;
  Vue.use(VueMoment);
};
