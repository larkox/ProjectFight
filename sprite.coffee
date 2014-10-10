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
    draw: (environment) ->
        if !@no_draw
            super(environment)
    clear: (environment) ->
        if @no_draw then @is_finished = true else super(environment)

    @attack_behaviours: {
        "static": (attack, environment) ->
        "straight": (attack, environment) ->
            attack.pos.x += if attack.direction == 0 then 1 else -1
            if attack.pos.x > environment.loop.state.stage.width
                attack.no_draw = true
        }
