class Sprite
    constructor: (@pos, definition) ->
        {"loaded": @l_image, "content": @image} = loadImage(definition.image)
        @dimensions = definition.dimensions
        acum = 0
        @sprite_start = for dimension in @dimensions
            aux = acum
            acum += dimension.h
            aux
        @frame = 0
        @current_sprite = 0
        @current_state = 0
    isReady: -> @l_image._
    getShowingRect: ->
        dim = @dimensions[@current_sprite]
        x = dim.w * @current_state
        y = @sprite_start[@current_sprite]
        {"x": x, "y": y, "w": dim.w, "h": dim.h}
    animate: (environment) ->
        @frame += 1
    draw: (environment) ->
        rect = @getShowingRect()
        environment.drawSprite(@image, rect, @pos)

class Piece extends Sprite
    constructor: (pos, definition) ->
        super(pos, definition)
        @attributes = definition.attributes

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
