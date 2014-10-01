loadImage = (src) ->
    result = {"loaded": {"_": false}, "content": new Image}
    result.content.onload = ->
        result.loaded._ = true
    result.content.src = src
    result
