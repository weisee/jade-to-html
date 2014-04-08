fs = require 'fs'
jade = require 'jade'

allowedFilenames = new RegExp('^.*\.jade$')
watchDir = '/'
destinationDir = '/'
data = {}
resultExtenstion = 'html'

module.exports = (currentDir, target, destDir, dataFile, resExt, watch) ->
  data = require(currentDir + '/' + dataFile)
  watchDir = currentDir + '/' + target 
  destinationDir = if destDir then currentDir + '/' + destDir else watchDir
  resultExtenstion = '.' + if resExt then resExt else resultExtenstion

  console.log 'Render to ', destinationDir
  console.log 'With extension ', resultExtenstion
  if watch
    console.log 'ASYNC MODE. Watch enabled.'
    walkAndRender watchDir
    fs.watch watchDir, handleWatch
  else
    console.log 'SYNC MODE.'
    walkAndRenderSync watchDir

walkAndRender = (dir) ->
  fs.readdir dir, (err, list) ->
    throw new Error(err) if err
    listLength = list.length
    return null if not listLength
    for file in list
      filename = dir + '/' + file
      renderOrWalk filename

walkAndRenderSync = (dir) ->
  list = fs.readdirSync dir
  throw list if list instanceof Error
  listLength = list.length
  return null if not listLength
  for file in list
    filename = dir + '/' + file
    renderOrWalkSync filename

renderOrWalk = (filename) ->
  fs.stat filename, (err, stat) ->
    throw new Error(err) if err
    if stat and stat.isDirectory()
      walkAndRender filename
    else 
      renderFile filename

renderOrWalkSync = (filename) ->
  stat = fs.statSync filename
  throw stat if stat instanceof Error
  if stat and stat.isDirectory()
    walkAndRenderSync filename
  else 
    renderFileSync filename

handleWatch = (event, filename) ->
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
    compileJadeFile filename, domain, data

renderFileSync = (filename) ->
  template = fs.readFileSync filename, encoding: 'utf8'
  throw template if template instanceof Error
  fn = jade.compile template
  throw fn if fn instanceof Error
  for domain, domainData of data.domains
    compiledPath = resolveCompiledPath filename, domain
    html = fn(domainData)
    throw html if html instanceof Error
    err = fs.writeFileSync compiledPath, html
    console.log compiledPath, ' compiled.'
    throw err if err

compileJadeFile = (filename, domain, data) ->
  data = data || {}
  jade.renderFile filename, data, (err, html) ->
    return console.error err if err
    compiledPath = resolveCompiledPath filename, domain 
    fs.writeFile compiledPath, html, (err) ->
      return console.error err if err
      console.log compiledPath, ' compiled.'
