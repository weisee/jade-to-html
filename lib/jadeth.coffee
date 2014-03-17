fs = require 'fs'
jade = require 'jade'
spawn = require('child_process').spawn

allowedFilenames = new RegExp('^.*\.jade$')
watchDir = '/'
destinationDir = '/'
data = {}
resultExtenstion = 'html'

module.exports = (currentDir, target, destDir, dataFile, resExt) ->
  data = require(currentDir + '/' + dataFile)
  watchDir = currentDir + '/' + target 
  destinationDir = if destDir then currentDir + '/' + destDir else watchDir
  resultExtenstion = '.' + if resExt then resExt else resultExtenstion

  console.log 'Start watching', watchDir
  console.log 'Render to ', destinationDir
  console.log 'With extension ', resultExtenstion

  walkAndRender watchDir
  fs.watch watchDir, handeWatch

walkAndRender = (dir) ->
  fs.readdir dir, (err, list) ->
    throw new Error(err) if err
    listLength = list.length
    return null if not listLength
    for file in list
      filename = dir + '/' + file
      renderOrWalk filename

renderOrWalk = (filename) ->
  fs.stat filename, (err, stat) ->
    throw new Error(err) if err
    if stat and stat.isDirectory()
      walkAndRender filename
    else 
      renderFile filename

handeWatch = (event, filename) ->
  return false if not allowedFilenames.test(filename)
  renderFile watchDir + '/' + filename

resolveCompiledPath = (filename, domain) ->
  filename = filename.replace /\.jade$/, resultExtenstion
  filename = filename.replace watchDir, ''
  filename = filename.replace /^\/*/, ''
  filename = filename.split('/').join('-')
  if domain
    fileDir = [destinationDir, domain].join('/')
    if not fs.existsSync fileDir
      fs.mkdirSync fileDir
    filename = [fileDir, filename].join('/')
  else
    filename = [destinationDir, filename].join('/')
  return filename


renderFile = (filename) ->
  for domain, data of data.domains
    console.log filename, domain, data
    compileJadeFile filename, domain, data


compileJadeFile = (filename, domain, data) ->
  data = data || {}
  jade.renderFile filename, data, (err, html) ->
    return console.log err if err
    compiledPath = resolveCompiledPath filename, domain 
    fs.writeFile compiledPath, html, (err) ->
      return console.log err if err
      console.log compiledPath, ' compiled.'
