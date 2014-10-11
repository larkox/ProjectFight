class Sprite
    constructor: (@pos, definition) ->
        {"loaded": @l_image, "content": @image} = loadImage(definition.image)
        @dimensions = definition.dimensions
        @frame_per_animation = definition.frames
        acum = 0
        @sprite_start = for dimension in @dimensions
            aux = acum
            acum += dimension.h
            aux
        @frame = 0
        @current_sprite = 0
        @current_state = 0
        @direction = 0
    isReady: -> @l_image._
    getShowingRect: ->
        dim = @dimensions[@current_sprite]
        x = (@direction * @image.width / 2) + (dim.w * @current_state)
        y = @sprite_start[@current_sprite]
        {"x": x, "y": y, "w": dim.w, "h": dim.h}
    animate: (environment) ->
        @frame += 1
        if (@frame % 10) == 0
            @current_state = (@current_state + 1) % @frame_per_animation[@current_sprite]
    draw: (environment) ->
        rect = @getShowingRect()
        environment.drawSprite(@image, rect, @pos)
    clear: (environment) ->
        dim = @dimensions[@current_sprite]
        rect = {"x": @pos.x, "y": @pos.y, "w": dim.w, "h": dim.h}
        environment.clear(rect)
    getRect: ->
        {
            "x": @pos.x, "y": @pos.y,
            "w": @dimensions[@current_sprite].w,
            "h": @dimensions[@current_sprite].h
        }

class Piece extends Sprite
    constructor: (pos, definition) ->
        super(pos, definition)
        @attributes = definition.attributes
    animate: (player, environment) ->
        @updateCurrentSprite(player.state, player.attack_info)
        super(environment)
    getBasePoint: ->
        if @attributes.base_points
            @attributes.base_points[@current_sprite][@direction]
        else
            [
                @attributes.legs_points[@current_sprite][@direction],
                @attributes.head_points[@current_sprite][@direction],
                @attributes.arms_points[@current_sprite][@direction],
            ]
    updateCurrentSprite: (player_state, attack_info) ->
        if !player_state.defend
            if !player_state.attack
                if player_state.crouch && @current_sprite != 1
                    @current_sprite = 1
                    @current_state = 0
                else if player_state.jump && @current_sprite != 2
                    @current_sprite = 2
                    @current_state = 0
                else if (
                        !player_state.crouch &&
                        !player_state.jump &&
                        @current_sprite != 0
                        )
                    @current_sprite = 0
                    @current_state = 0
            else
                if player_state.crouch && @current_sprite != 1
                    @current_sprite = 1
                    @current_state = 0
                else if player_state.jump && @current_sprite != 2
                    @current_sprite = 2
                    @current_state = 0
                else if (
                        !player_state.crouch &&
                        !player_state.jump &&
                        @current_sprite != attack_info.current_sprite
                        )
                    @current_sprite = attack_info.current_sprite
                    @current_state = 0
        else if player_state.crouch && @current_sprite != 3
            @current_sprite = 3
            @current_state = 0
        else if player_state.jump && @current_sprite != 3
            @current_sprite = 3
            @current_state = 0
        else if (
            !player_state.crouch &&
            !player_state.jump &&
            @current_sprite != 3
            )
            @current_sprite = 3
            @current_state = 0

class AttackDefinition extends Sprite
    constructor: (definition) ->
        super({"x": 0, "y": 0}, definition)
        @base_points = definition.base_points
        @type = definition.type
        @multiplier = definition.multiplier
    @loadAttacks: (environment, definition) ->
        result = {}
        for key, value of definition
            result[key] = new AttackDefinition(environment.data.attacks[value])
        result

class Attack extends Sprite
    constructor: (@pos, definition, power, s_power, @owner) ->
        @l_image = true
        @image = definition.image
        @dimensions = definition.dimensions
        @frame_per_animation = definition.frame_per_animation
        acum = 0
        @sprite_start = definition.sprite_start
        @frame = 0
        @current_sprite = 0
        @current_state = 0
        @direction = @owner.direction
        @base_points = definition.base_points
        @type = definition.type
        @power = switch
            when @type == "normal" then power
            when @type == "special" then s_power
            when @type == "mixed" then (power + s_power) / 2
            else throw("Unrecognized attack type.")
        @power = @power * definition.multiplier
        @no_draw = false
        @is_finished = false
    animate: (environment) ->
        Attack.attack_behaviours.straight(this, environment)
        @frame += 1
        if (@frame % 10) == 0
            @current_state += 1
        if @current_state >= @frame_per_animation[@current_sprite]
            @current_sprite += 1
            @current_state = 0
        if @current_sprite >= @frame_per_animation.length
            @no_draw = true
        unless @no_draw
            @checkCollision(environment)
    draw: (environment) ->
        if !@no_draw
            super(environment)
    clear: (environment) ->
        if @no_draw then @is_finished = true else super(environment)
    checkCollision: (environment) ->
        foe = if environment.loop.state.p1 == @owner then environment.loop.state.p2 else environment.loop.state.p1
        thisRect = @getRect()
        if (rectCollide(thisRect, foe.bounding_rect))
            if (
                rectCollide(thisRect, foe.legs.getRect()) or
                rectCollide(thisRect, foe.body.getRect()) or
                rectCollide(thisRect, foe.head.getRect()) or
                rectCollide(thisRect, foe.arms.getRect()))
                @no_draw = true
                foe.receiveDamage(environment, @power, @type)
    @attack_behaviours: {
        "static": (attack, environment) ->
        "straight": (attack, environment) ->
            attack.pos.x += if attack.direction == 0 then 1 else -1
            if attack.pos.x > environment.loop.state.stage.width
                attack.no_draw = true
        }


rectCollide = ({"x": x1,"y": y1,"w": w1,"h": h1}, {"x": x2,"y": y2,"w": w2,"h": h2}) ->
    x = (x1 <= x2 <= x1 + w1) or (x2 <= x1 <= x2 + w2)
    y = (y1 <= y2 <= y1 + h1) or (y2 <= y1 <= y2 + h2)
    x and y
