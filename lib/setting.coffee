config = require './config.json'
console.log config.tpl


module.exports = 
    viewPath: config.tpl['path']
