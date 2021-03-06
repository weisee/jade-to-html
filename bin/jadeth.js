#!/usr/bin/env node
var curDir, dest, jadeth, path, resultExtension, optionsFile, watch;

jadeth = require('../lib/jadeth');

/*
For compile and watch your jade files you should exec next command:
  jadeth /templates /compiled_templates hbs jade_data.js
*/


curDir = process.cwd();

path = process.argv[2];

dest = process.argv[3];

resultExtension = process.argv[4];

watch = process.argv[6] || false;

if (~['false', 'no', 'none', 'no-watch', false].indexOf(watch)) {
  watch = false
} else {
  watch = true
}


/*
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
*/


optionsFile = process.argv[5] ? process.argv[5] : resultExtension;

jadeth(curDir, path, dest, optionsFile, resultExtension, watch);

