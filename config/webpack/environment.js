const { environment } = require("@rails/webpacker");
const customConfig = require("./custom");
const { VueLoaderPlugin } = require("vue-loader");
const VuetifyLoaderPlugin = require("vuetify-loader/lib/plugin");

const vue = require("./loaders/vue");
const erb = require("./loaders/erb");
const sass = require("./loaders/sass");
const scss = require("./loaders/scss");

environment.loaders.delete("moduleSass");
environment.loaders.delete("moduleCss");
environment.loaders.delete("sass");
environment.loaders.delete("nodeModules");

environment.plugins.prepend("VuetifyLoaderPlugin", new VuetifyLoaderPlugin());
environment.plugins.prepend("VueLoaderPlugin", new VueLoaderPlugin());

environment.loaders.append("vue", vue);
environment.loaders.append("erb", erb);
environment.loaders.append("sass", sass);
environment.loaders.append("scss", scss);

environment.config.merge(customConfig);
module.exports = environment;
