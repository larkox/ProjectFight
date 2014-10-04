loadSound = (environment, src) ->
    result = {"loaded": {"_": false}, "content": {}}
    request = new XMLHttpRequest()
    request.open("GET", src, true);
    request.responseType = "arraybuffer";
    request.onload = ->
        if (@readyState == 4)
            environment.sound_context.decodeAudioData(@response, ((buffer) -> (
                result.loaded._ = true
                result.content._ = buffer
            )), -> );
    request.send()
    result

playSound = (environment, buffer) ->
    source = environment.sound_context.createBufferSource()
    source.buffer = buffer
    source.connect(environment.sound_context.destination)
    source.start(0)
