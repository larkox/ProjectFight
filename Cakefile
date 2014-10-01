fs = require "fs"
{exec} = require "child_process"
util = require "util"

prodSrcCoffeeDir = "."
dataSrcCoffeeDir = "./src/data"
testSrcCoffeeDir = "."

prodTargetJsDir = "."
testTargetJsDir = "."

prodTargetFileName = "app"
prodTargetCoffeeFile = "#{prodSrcCoffeeDir}/#{prodTargetFileName}.coffee"
prodTargetJsFile = "#{prodTargetJsDir}/#{prodTargetFileName}.js"

prodCoffeeOpts = "--bare --output #{prodTargetJsDir} --compile #{prodTargetCoffeeFile}"
testCoffeeOpts = "--output #{testTargetJsDir}"

dataCoffeeFiles = [
    "constants",
    "pieces",
    "attacks",
]

prodCoffeeFiles = [
    "environment",
    "loop",
    "sprite",
    "images",
]

task("build", "build the project", ->
    util.log "Building #{prodTargetJsFile}"
    appContents = new Array(remaining = (dataCoffeeFiles.length + prodCoffeeFiles.length))
    for file, index in dataCoffeeFiles then do (file, index) ->
        fs.readFile("#{dataSrcCoffeeDir}/#{file}.coffee", "utf8", (err, fileContents) ->
            util.log(err) if err

            appContents[index] = fileContents
            util.log "[#{index + 1}] #{file}.coffee"
            process() if --remaining is 0
        )

    for file, index in prodCoffeeFiles then do (file, index) ->
        index += dataCoffeeFiles.length
        fs.readFile("#{prodSrcCoffeeDir}/#{file}.coffee", "utf8", (err, fileContents) ->
            util.log(err) if err

            appContents[index] = fileContents
            util.log "[#{index + 1}] #{file}.coffee"
            process() if --remaining is 0
        )

    process = ->
        fs.writeFile(prodTargetCoffeeFile, appContents.join("\n\n"), "utf8", (err) ->
            util.log(err) if err

            exec("coffee #{prodCoffeeOpts}", (err, stdout, stderr) ->
                util.log(err) if err
                message = "Compiled #{prodTargetJsFile}"
                util.log(message)
                fs.unlink(prodTargetCoffeeFile, (err) -> util.log(err) if err)
            )
        )
)
