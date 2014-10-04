class Stage
    constructor: (def) ->
        {"loaded": @l_background, "content": @background} = loadImage(def.background_img)
        {"loaded": @l_foreground, "content": @foreground} = loadImage(def.foreground_img)
        {
            @background_height,
            @background_frames,
            @foreground_height,
            @foreground_frames,
            @foreground_loc,
            @base_line,
            @width
        }  = def
        @dirty = true
        @background_using_frame = 0
        @foreground_using_frame = 0
        @frame = 0
    isReady: -> @l_background._ & @l_foreground._
    animate: (environment) ->
        @frame += 1
        if (@frame % 10) == 0
            @foreground_using_frame = (@foreground_using_frame + 1) % @foreground_frames
            @background_using_frame = (@background_using_frame + 1) % @background_frames
            @dirty = true
    draw: (environment) ->
        if @dirty
            rect = {
                "x": environment.loop.state.scroll,
                "y": @background_using_frame * @background_height,
                "w": environment.width,
                "h": @background_height
            }
            pos = {"x": 0, "y": 0}
            environment.drawBackground(@background, rect, pos)
            clearRect = {
                "x": 0,
                "y": @foreground_loc,
                "w": environment.width,
                "h": @foreground_height,
            }
            rect = {
                "x": environment.loop.state.scroll,
                "y": @foreground_using_frame * @foreground_height,
                "w": environment.width,
                "h": @foreground_height
            }
            pos = {"x": 0, "y": @foreground_loc}
            environment.clearForeground(clearRect)
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
