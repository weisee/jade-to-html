jadeth = require '../lib/jadeth'


###
For compile and watch your jade files you should exec next command:
  jadeth /templates /compiled_templates hbs jade_data.js
###

curDir = process.cwd()
path = process.argv[2]
dest = process.argv[3]
resultExtension = process.argv[4]



###
Options file should have such structure:
  module.exports = {
    domains: {
      ru: {
        _t: function(term) {
          return 'По-русски будет ' + term
        },
      },
      en: {
        _t: function(term) {
          return 'In english ' + term
        },
      },
    },
}
###
optionsFile if process.argv[5] then process.argv[5] else resultExtension

# Start compiller
jadeth(curDir, path, dest, optionsFile, resultExtension)
