class Stage
    constructor: (def) ->
        {"loaded": @l_background, "content": @background} = loadImage(def.background_img)
        {"loaded": @l_foreground, "content": @foreground} = loadImage(def.foreground_img)
        {@foreground_loc, @base_line} = def
        @dirty = true
    isReady: -> @l_background._ & @l_foreground._
    animate: (environment) ->
    draw: (environment) ->
        #if @dirty
            rect = {
                "x": environment.loop.state.scroll,
                "y": 0,
                "w": environment.width,
                "h": @background.height
            }
            pos = {"x": 0, "y": 0}
            environment.drawBackground(@background, rect, pos)
            rect = {
                "x": environment.loop.state.scroll,
                "y": 0,
                "w": environment.width,
                "h": @foreground.height
            }
            pos = {"x": 0, "y": @foreground_loc}
            environment.drawForeground(@foreground, rect, pos)
            @dirty = false

loadStage = (def) ->
    result = {
        "loaded": {"_": false},
        "content": new Stage(def)
    }
    check = (result) ->
        if result.content.isReady()
            result.loaded._ = true
        else
            setTimeout((-> check(result)), 100)
    check(result)
    result
