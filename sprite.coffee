class Sprite
    constructor: (@pos, definition) ->
        @limage = false
        @image = new Image
        @image.onload = ->
            @limage = true
        @image.src = definition.image
        @dimensions = definition.dimensions
        acum = 0
        @sprite_start = for dimension in @dimensions
            aux = acum
            acum += dimension.h
            aux
        @frame = 0
        @current_sprite = 0
        @current_state = 0
    getShowingRect: ->
        dim = @dimensions[@current_sprite]
        x = dim.w * current_state
        y = @sprite_start[@current_sprite]
        {"x": x, "y": y, "w": dim.w, "h": dim.h}
    animate: (environment) ->
        @frame += 1
    draw: (environment) ->
        rect = @getShowingRect
        environment.drawSprite(image, rect, @translate(pos))
    translate: (pos) -> pos

class Piece extends Sprite
    constructor: (pos, definition) ->
        super(pos, definition)
        @attributes = definition.attributes
    translate: (pos) ->
        result = {}
        result.x = pos.x - @attributes.base_points(@current_sprite).x
        result.y = pos.y - @attributes.base_points(@current_sprite).y
        result

class Attack extends Sprite
    constructor: (pos, definition, power, s_power, @owner) ->
        super(pos, definition)
        @base_points = definition.base_points
        @type = definition.type
        @power = switch
            when @type == "normal" then power
            when @type == "special" then s_power
            when @type == "mixed" then (power + s_power) / 2
            else throw("Unrecognized attack type.")
        @power = @power * definition.multiplier
    translate: (pos) ->
        result = {}
        result.x = pos.x - @base_points(@current_sprite).x
        result.y = pos.y - @base_points(@current_sprite).y
        result
