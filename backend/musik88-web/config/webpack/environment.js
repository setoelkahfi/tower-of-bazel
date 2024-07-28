const { environment } = require('@rails/webpacker')
const custom = {
    resolve: {
        alias: {
            jquery: 'jquery/src/jquery',
        }
    }
}
environment.config.merge(custom)

module.exports = environment
