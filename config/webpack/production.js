process.env.NODE_ENV = process.env.NODE_ENV || 'production'

const environment = require('./environment')
const config = environment.toWebpackConfig()

config.optimization.minimizer[0].options.sourceMap = false

module.exports = config
