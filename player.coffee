class Player
    constructor: (environment, def, @pos) ->
        @legs = new Piece(pos, environment.data.pieces[def.legs])
        @body = new Piece(pos, environment.data.pieces[def.body])
        @head = new Piece(pos, environment.data.pieces[def.head])
        @arms = new Piece(pos, environment.data.pieces[def.arms])
        @max_weight = @legs.attributes.max_weight
        @weight = @legs.attributes.weight +
            @body.attributes.weight +
            @head.attributes.weight +
            @arms.attributes.weight
        @state = "idle"
        @s_power = @head.attributes.special_power
        @a_power = @arms.attributes.power
        @l_power = @legs.attributes.power
        @defense = @body.attributes.defense
        @s_defense = @body.attributes.special_defense
        @a_defense = @arms.attributes.defense
        @hit_points = @body.attributes.hit_points
        movement_multiplier = @calculateMovementMultiplier()
        @movement = Math.round(@legs.attributes.movement * movement_multiplier)
        @jump = @legs.attributes.jump * movement_multiplier
        @y_speed = 0
        @bounding_rect = @getBoundingRect()
    isReady: ->
        @legs.isReady() &
        @body.isReady() &
        @head.isReady() &
        @arms.isReady()
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
        legs_point.x = @pos.x - scroll - @legs.image.width/2
        legs_point.y = base - @pos.y - @legs.image.height
        @legs.pos = legs_point

        body_point = {}
        body_point.x = legs_point.x +
            @legs.attributes.base_points[@legs.current_sprite].x -
            @body.attributes.legs_points[@body.current_sprite].x
        body_point.y = legs_point.y +
            @legs.attributes.base_points[@legs.current_sprite].y -
            @body.attributes.legs_points[@body.current_sprite].y
        @body.pos = body_point

        head_point = {}
        head_point.x = body_point.x +
            @body.attributes.head_points[@body.current_sprite].x -
            @head.attributes.base_points[@head.current_sprite].x
        head_point.y = body_point.y +
            @body.attributes.head_points[@body.current_sprite].y -
            @head.attributes.base_points[@head.current_sprite].y
        @head.pos = head_point

        arms_point = {}
        arms_point.x = body_point.x +
            @body.attributes.arms_points[@body.current_sprite].x -
            @arms.attributes.base_points[@arms.current_sprite].x
        arms_point.y = body_point.y +
            @body.attributes.arms_points[@body.current_sprite].y -
            @arms.attributes.base_points[@arms.current_sprite].y
        @arms.pos = arms_point

        @head.draw(environment)
        @body.draw(environment)
        @arms.draw(environment)
        @legs.draw(environment)
        @bounding_rect = @getBoundingRect()
    animate: (environment) ->
        if environment.keys[environment.constants.KEY_LEFT]
            @pos.x -= @movement
            @pos.x = Math.max(environment.constants.LIMIT_LEFT, @pos.x)
        if environment.keys[environment.constants.KEY_RIGHT]
            @pos.x += @movement
            @pos.x = Math.min(environment.loop.state.stage.width - environment.constants.LIMIT_RIGHT, @pos.x)
        if environment.keys[environment.constants.KEY_UP] && @state == "idle"
            @y_speed = @jump
            @state = "jump"
        @pos.y += Math.floor(@y_speed)
        @y_speed -= environment.constants.GRAVITY
        if @pos.y < 0
            @pos.y = 0
            @state = "idle"
            @y_speed = 0
    calculateMovementMultiplier: ->
        rate = @weight / @max_weight
        if rate < 0 then 1.5
        else if rate < 0.5 then 1
        else if rate < 0.75 then 0.75
        else if rate < 0.90 then 0.50
        else if rate < 1 then 0.25
        else 0


loadPlayer = (environment, def, pos) ->
    result = {
        "loaded": {"_": false},
        "content": new Player(environment, def, pos)
    }
    check = (result) ->
        if result.content.isReady()
            result.loaded._ = true
        else
            setTimeout((-> check(result)), 100)
    check(result)
    result
