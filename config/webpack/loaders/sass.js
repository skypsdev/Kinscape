module.exports = {
  test: /\.sass$/,
  use: [
    'vue-style-loader',
    {
      loader: 'css-loader',
      options: {
        sourceMap: true,
        importLoaders: 2
      }
    },
    {
      loader: 'sass-loader',
      options: {
        sourceMap: true,
        implementation: require('sass'),
        additionalData: '@import "app/javascript/assets/styles/main.scss"'
      }
    }
  ]
}
