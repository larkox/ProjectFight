class Loop
    constructor: (environment) ->
        @state = {}
    isReady: -> true
    animate: (environment) ->
    draw: (environment) ->
    onKeyDown: (event) ->
    onKeyUp: (event) ->
    onMouseDown: (event) ->
    onMouseUp: (event) ->
    onMouseMove: (event) ->

class GameLoop extends Loop
    constructor: (environment, p1_def, p2_def, stage) ->
        super(environment)
        environment.clean()
        @state.dirty = true
        @state.frame_time = 1/32
        {l_p1, p1} = loadPlayer(p1_def)
        @state.l_p1 = l_p1
        @state.p1 = p1
        {l_p2, p2} = loadPlayer(p2_def)
        @state.l_p2 = l_p2
        @state.p2 = p2
        {l_stage, stage} = loadStage(stage)
        @state.l_stage = l_stage
        @state.stage = stage
    isReady: -> (state.l_p1._ & state.l_p2._ & state.l_stage._)
    animate: (environment) ->
        @p1.animate(environment)
        @p2.animate(environment)
        @stage.animate(environment)
    draw: (environment) ->
        @p1.draw(environment)
        @p2.draw(environment)
        @stage.draw(environment)

class MainMenuLoop extends Loop
    constructor: (environment) ->
        super(environment)
        environment.clean()
        @state.selected = 0
        @state.previous = 0
        @state.dirty = true
        @state.frame_time = 1/16
        {@l_background, @background} = loadImage("src/images/main_menu_background.png")
        {@l_buttons, @buttons} = loadImage("src/images/main_menu_buttons.png")
        {@l_sel_buttons, @sel_buttons} = loadImage("src/images/main_menu_sel_butons.png")
    draw: (environment) ->
        if dirty
            environment.drawBackground(@background, 0, 0, environment.width, environment.height)
            environment.drawBackground(@buttons,
                environment.constants.MENU_BUTTONS_POS.x,
                environment.constants.MENU_BUTTONS_POS.y,
                environment.constants.MENU_BUTTONS_WIDTH,
                environment.constants.MENU_BUTTONS_HEIGHT)
        if @state.selected != @state.previous
            rect = calculateClearArea()
            environment.clear(rect)
            rect = calculateButtonSprite()
            pos = calculateButtonPos()
            environment.drawSprite(@sel_buttons, rect, pos)
    calculateButtonSprite: ->
        x = 0
        y = @state.selected * environment.constants.MENU_BUTTON_HEIGHT
        width = environment.constants.MENU_BUTTONS_WIDTH
        height = environment.constants.MENU_BUTTON_HEIGHT
        {"x": x, "y": y, "w": width, "h": height}
    calculateButtonPos: ->
        x = environment.constants.MENU_BUTTONS_POS.x
        y = environment.constants.MENU_BUTTONS_POS.y +
            environment.constants.MENU_BUTTON_HEIGHT * @state.selected
        {"x": x, "y": y}
    calculateClearArea: ->
        x = environment.constants.MENU_BUTTONS_POS.x
        y = environment.constants.MENU_BUTTONS_POS.y +
            environment.constants.MENU_BUTTON_HEIGHT * @state.selected
        width = environment.constants.MENU_BUTTONS_WIDTH
        height = environment.constants.MENU_BUTTON_HEIGHT
        {"x": x, "y": y, "w": width, "h": height}
    onKeyDown: (event) ->
        switch event.keyCode
            when environment.constants.KEY_UP
                @state.previous = @state.selected
                @state.selected = (@state.selected - 1) %% environment.constants.MENU_NUM_ELEM
            when environment.constants.KEY_UP
                @state.previous = @state.selected
                @state.selected = (@state.selected + 1) % environment.constants.MENU_NUM_ELEM
            when environment.constants.KEY_ENTER
                switch @state.selected
                    when 0
                        environment.loop = null
