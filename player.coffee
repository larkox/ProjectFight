class Player
    constructor: (environment, def, @pos, human) ->
        @legs = new Piece(pos, environment.data.pieces[def.legs])
        @body = new Piece(pos, environment.data.pieces[def.body])
        @head = new Piece(pos, environment.data.pieces[def.head])
        @arms = new Piece(pos, environment.data.pieces[def.arms])
        {"loaded": @l_jump_sound, "content": @jump_sound} = loadSound(environment, "src/sound/jump_001.ogg")
        @max_weight = @legs.attributes.max_weight
        @weight = @legs.attributes.weight +
            @body.attributes.weight +
            @head.attributes.weight +
            @arms.attributes.weight
        @state = {
            "crouch": false,
            "jump": false,
            "defend": false,
        }
        @s_power = @head.attributes.special_power
        @a_power = @arms.attributes.power
        @l_power = @legs.attributes.power
        @defense = @body.attributes.defense
        @s_defense = @body.attributes.special_defense
        @a_defense = @arms.attributes.defense
        @hit_points = @body.attributes.hit_points
        movement_multiplier = @calculateMovementMultiplier()
        @movement = Math.round(@legs.attributes.movement * movement_multiplier)
        @jump_strength = @legs.attributes.jump * movement_multiplier
        @y_speed = 0
        @bounding_rect = @getBoundingRect()
        if (human == 1)
            @animation_behaviour = animateAsP1
        else if human == 2
            @animation_behaviour = animateAsP2
        else
            @animation_behaviour = animateAsCPU
    isReady: ->
        @legs.isReady() &
        @body.isReady() &
        @head.isReady() &
        @arms.isReady() &
        @l_jump_sound._
    getBoundingRect: ->
        x = @legs.pos.x
        x2 = @legs.pos.x + @legs.dimensions[@legs.current_sprite].w
        y = @legs.pos.y
        y2 = @legs.pos.y + @legs.dimensions[@legs.current_sprite].h
        x_min = x
        x_max = x2
        y_min = y
        y_max = y2
        x = @body.pos.x
        x2 = @body.pos.x + @body.dimensions[@body.current_sprite].w
        y = @body.pos.y
        y2 = @body.pos.y + @body.dimensions[@body.current_sprite].h
        x_min = Math.min(x_min, x)
        x_max = Math.max(x_max, x2)
        y_min = Math.min(y_min, y)
        y_max = Math.max(y_max, y2)
        x = @head.pos.x
        x2 = @head.pos.x + @head.dimensions[@head.current_sprite].w
        y = @head.pos.y
        y2 = @head.pos.y + @head.dimensions[@head.current_sprite].h
        x_min = Math.min(x_min, x)
        x_max = Math.max(x_max, x2)
        y_min = Math.min(y_min, y)
        y_max = Math.max(y_max, y2)
        x = @arms.pos.x
        x2 = @arms.pos.x + @arms.dimensions[@arms.current_sprite].w
        y = @arms.pos.y
        y2 = @arms.pos.y + @arms.dimensions[@arms.current_sprite].h
        x_min = Math.min(x_min, x)
        x_max = Math.max(x_max, x2)
        y_min = Math.min(y_min, y)
        y_max = Math.max(y_max, y2)
        {"x": x_min, "y": y_min, "w": x_max - x_min, "h": y_max - y_min}
    clear: (environment) ->
        environment.clear(@bounding_rect)
    draw: (environment) ->
        scroll = environment.loop.state.scroll
        base = environment.loop.state.stage.base_line
        legs_point = {}
        legs_point.x = @pos.x - scroll - @legs.dimensions[@legs.current_sprite].w/2
        legs_point.y = base - @pos.y - @legs.dimensions[@legs.current_sprite].h
        @legs.pos = legs_point

        body_point = {}
        legs_base_point = @legs.getBasePoint()
        body_base_points = @body.getBasePoint()
        head_base_point = @head.getBasePoint()
        arms_base_point = @arms.getBasePoint()

        body_point.x = legs_point.x +
            legs_base_point.x -
            body_base_points[0].x
        body_point.y = legs_point.y +
            legs_base_point.y -
            body_base_points[0].y
        @body.pos = body_point

        head_point = {}
        head_point.x = body_point.x +
            body_base_points[1].x -
            head_base_point.x
        head_point.y = body_point.y +
            body_base_points[1].y -
            head_base_point.y
        @head.pos = head_point

        arms_point = {}
        arms_point.x = body_point.x +
            body_base_points[2].x -
            arms_base_point.x
        arms_point.y = body_point.y +
            body_base_points[2].y -
            arms_base_point.y
        @arms.pos = arms_point

        @head.draw(environment)
        @body.draw(environment)
        @arms.draw(environment)
        @legs.draw(environment)
        @bounding_rect = @getBoundingRect()
    animate: (environment) ->
        @animation_behaviour(environment, this)
        if @state.jump
            @pos.y += Math.floor(@y_speed)
            @y_speed -= environment.constants.GRAVITY
            if @pos.y < 0
                @pos.y = 0
                @y_speed = 0
                @state.jump = false
        @legs.animate(@state, environment)
        @body.animate(@state, environment)
        @head.animate(@state, environment)
        @arms.animate(@state, environment)
    calculateMovementMultiplier: ->
        rate = @weight / @max_weight
        if rate < 0 then 1.5
        else if rate < 0.5 then 1
        else if rate < 0.75 then 0.75
        else if rate < 0.90 then 0.50
        else if rate < 1 then 0.25
        else 0
    canMove: ->
        !@state.crouch & !@state.defend
    canJump: ->
        !@state.crouch & !@state.jump & !@state.defend
    canCrouch: ->
        !@state.jump
    canDefend: ->
        true
    move: (environment, direction) ->
        @pos.x += @movement * direction
        @pos.x = Math.max(environment.constants.LIMIT_LEFT, @pos.x)
        @pos.x = Math.min(environment.loop.state.stage.width - environment.constants.LIMIT_RIGHT, @pos.x)
        @direction = if direction == -1 then 1 else 0
        @legs.direction = @direction
        @head.direction = @direction
        @arms.direction = @direction
        @body.direction = @direction
    jump: (environment) ->
        @y_speed = @jump_strength
        @state.jump = true
        playSound(environment, @jump_sound._)


loadPlayer = (environment, def, pos, human) ->
    result = {
        "loaded": {"_": false},
        "content": new Player(environment, def, pos, human)
    }
    check = (result) ->
        if result.content.isReady()
            result.loaded._ = true
        else
            setTimeout((-> check(result)), 100)
    check(result)
    result

animateAsP1 = (environment, player) ->
    if environment.keys[environment.constants.KEY_LEFT] && player.canMove()
        player.move(environment, -1)
    if environment.keys[environment.constants.KEY_RIGHT] && player.canMove()
        player.move(environment, +1)
    if environment.keys[environment.constants.KEY_UP] && player.canJump()
        player.jump(environment)
    if environment.keys[environment.constants.KEY_DOWN] && player.canCrouch()
        player.state.crouch = true
    else
        player.state.crouch = false
    if environment.keys[environment.constants.BUTTON_BLOCK] && player.canDefend()
        player.state.defend = true
    else
        player.state.defend = false

animateAsCPU = (environment, player) ->
    foe = if environment.loop.state.p1 == player then environment.loop.state.p2 else environment.loop.state.p1
    if foe.state.jump & player.canCrouch()
        player.state.crouch = true
    else if foe.state.crouch & player.canJump()
        player.jump(environment)
    else if 0 < Math.abs(foe.pos.x - player.pos.x) < 30 & player.canDefend()
        player.state.defend = true
    else if 0 < (foe.pos.x - player.pos.x) < 60 & player.canMove()
        player.move(environment, -1)
    else if 0 > (foe.pos.x - player.pos.x) > -60 & player.canMove()
        player.move(environment, +1)
    else if (foe.pos.x - player.pos.x) >= 80
        player.state.crouch = false
        player.state.defend = false
        player.move(environment, +1)
    else if (foe.pos.x - player.pos.x) <= -80
        player.state.crouch = false
        player.state.defend = false
        player.move(environment, -1)
