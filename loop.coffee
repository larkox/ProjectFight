class Loop
    constructor: (environment) ->
        @state = {}
    isReady: -> true
    frame_time = 1000/32
    animate: (environment) ->
    draw: (environment) ->
    onKeyDown: (event, environment) ->
    onKeyUp: (event, environment) ->
    onMouseDown: (event, environment) ->
    onMouseUp: (event, environment) ->
    onMouseMove: (event, environment) ->

class GameLoop extends Loop
    constructor: (environment, p1_def, p2_def, stage) ->
        super(environment)
        environment.clean()
        @state.dirty = true
        @frame_time = 1000/32
        {"loaded": @l_p1, "content": @state.p1} = loadPlayer(p1_def)
        {"loaded": @l_p2, "content": @state.p2} = loadPlayer(p2_def)
        {"loaded": @l_stage, "content": @state.stage} = loadStage(stage)
    isReady: -> (@l_p1._ & @l_p2._ & @l_stage._)
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
        @frame_time = 1000/16
        {"loaded": @l_background, "content": @background} = loadImage("src/images/main_menu_background.png")
        {"loaded": @l_buttons, "content": @buttons} = loadImage("src/images/main_menu_buttons.png")
        {"loaded": @l_sel_buttons, "content": @sel_buttons} = loadImage("src/images/main_menu_sel_buttons.png")
    isReady: -> @l_background._ & @l_buttons._ & @l_sel_buttons._
    draw: (environment) ->
        if @state.dirty
            environment.drawBackground(@background, 0, 0, environment.width, environment.height)
            environment.drawBackground(@buttons,
                environment.constants.MENU_BUTTONS_POS.x,
                environment.constants.MENU_BUTTONS_POS.y,
                environment.constants.MENU_BUTTONS_WIDTH,
                environment.constants.MENU_BUTTONS_HEIGHT)
            rect = @calculateButtonSprite(environment)
            pos = @calculateButtonPos(environment)
            environment.drawSprite(@sel_buttons, rect, pos)
            @state.dirty = false
        if @state.selected != @state.previous
            rect = @calculateClearArea(environment)
            environment.clear(rect)
            rect = @calculateButtonSprite(environment)
            pos = @calculateButtonPos(environment)
            environment.drawSprite(@sel_buttons, rect, pos)
    calculateButtonSprite: (environment) ->
        x = 0
        y = @state.selected * environment.constants.MENU_BUTTON_HEIGHT
        width = environment.constants.MENU_BUTTONS_WIDTH
        height = environment.constants.MENU_BUTTON_HEIGHT
        {"x": x, "y": y, "w": width, "h": height}
    calculateButtonPos: (environment) ->
        x = environment.constants.MENU_BUTTONS_POS.x
        y = environment.constants.MENU_BUTTONS_POS.y +
            environment.constants.MENU_BUTTON_HEIGHT * @state.selected
        {"x": x, "y": y}
    calculateClearArea: (environment) ->
        x = environment.constants.MENU_BUTTONS_POS.x
        y = environment.constants.MENU_BUTTONS_POS.y +
            environment.constants.MENU_BUTTON_HEIGHT * @state.previous
        width = environment.constants.MENU_BUTTONS_WIDTH
        height = environment.constants.MENU_BUTTON_HEIGHT
        {"x": x, "y": y, "w": width, "h": height}
    onKeyUp: (event, environment) ->
        switch event.keyCode
            when environment.constants.KEY_UP
                @state.previous = @state.selected
                @state.selected = (@state.selected - 1) %% environment.constants.MENU_NUM_ELEM
            when environment.constants.KEY_DOWN
                @state.previous = @state.selected
                @state.selected = (@state.selected + 1) % environment.constants.MENU_NUM_ELEM
            when environment.constants.KEY_ENTER
                switch @state.selected
                    when 0
                        environment.loop = new GameLoop(environment, environment.data.players[0], environment.data.players[0], environment.data.stages[0])
