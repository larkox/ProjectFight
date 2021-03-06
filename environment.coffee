class Environment
    constructor: ->
        @layers = []
        @layers[0] = $("#backLayer")[0].getContext("2d")
        @layers[1] = $("#middleLayer")[0].getContext("2d")
        @layers[2] = $("#frontLayer")[0].getContext("2d")
        @width = @layers[0].canvas.width
        @height = @layers[0].canvas.height
        @loop = new MainMenuLoop(this)
        @loading = true
        @constants = constants
        @keys = {}
        @data = {pieces, attacks, players, stages}
        @sound_context = new AudioContext()
        document.onkeydown = (event) => @onKeyDown(event)
        document.onkeyup = (event) => @onKeyUp(event)
        document.onmousedown = (event) => @onMouseDown(event)
        document.onmouseup = (event) => @onMouseUp(event)
        document.onmousemove = (event) => @onMouseMove(event)
        setTimeout((=> @tick()), @loop.frame_time)
        @alphaCollision = {}
        @alphaCollision.canvas1 = document.createElement("canvas").getContext("2d")
        @alphaCollision.canvas2 = document.createElement("canvas").getContext("2d")
    drawSprite: (img, rect, pos) ->
        @layers[1].drawImage(img, rect.x, rect.y, rect.w, rect.h,
            pos.x, pos.y, rect.w, rect.h)
    drawBackground: (img, rect, pos) ->
        @layers[0].drawImage(img, rect.x, rect.y, rect.w, rect.h,
            pos.x, pos.y, rect.w, rect.h)
    drawForeground: (img, rect, pos) ->
        @layers[2].drawImage(img, rect.x, rect.y, rect.w, rect.h,
            pos.x, pos.y, rect.w, rect.h)
    clean: ->
        @layers[0].clearRect(0, 0, @width, @height)
        @layers[1].clearRect(0, 0, @width, @height)
        @layers[2].clearRect(0, 0, @width, @height)
    clear: ({x,y,w,h}) ->
        @layers[1].clearRect(x, y, w, h)
    clearForeground: ({x, y, w, h}) ->
        @layers[2].clearRect(x, y, w, h)
    tick: ->
        if @loading
            @loading = !@loop.isReady()
            setTimeout((=> @tick()), @loop.frame_time)
        else
            @loop.clear(this)
            @loop.animate(this)
            @loop.draw(this)
            setTimeout((=> @tick()), @loop.frame_time)
    onKeyDown: (event) ->
        if !@loading
            @keys[event.keyCode] = true
            @loop.onKeyDown(event, this)
    onKeyUp: (event) ->
        if !@loading
            @keys[event.keyCode] = false
            @loop.onKeyUp(event, this)
    onMouseDown: (event) ->
        if !@loading
            @loop.onMouseDown(event, this)
    onMouseUp: (event) ->
        if !@loading
            @loop.onMouseUp(event, this)
    onMouseMove: (event) ->
        if !@loading
            @loop.onMouseMove(event, this)
