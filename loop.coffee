class Loop
    constructor: (environment) ->
        @state = {}
    isReady: -> true
    frame_time = 1000/32
    clear: (environment) ->
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
        @state.scroll = 0
        @frame_time = 1000/32
        {"loaded": @l_p1, "content": @state.p1} = loadPlayer(environment, p1_def, environment.constants.P1_INIT_POS)
        {"loaded": @l_p2, "content": @state.p2} = loadPlayer(environment, p2_def, environment.constants.P2_INIT_POS)
        {"loaded": @l_stage, "content": @state.stage} = loadStage(stage)
    isReady: -> (@l_p1._ & @l_p2._ & @l_stage._)
    animate: (environment) ->
        @state.p1.animate(environment)
        @state.p2.animate(environment)
        @state.stage.animate(environment)
    draw: (environment) ->
        @state.p1.draw(environment)
        @state.p2.draw(environment)
        @state.stage.draw(environment)
    clear: (environment) ->
        @state.p1.clear(environment)
        @state.p2.clear(environment)

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
            rect = {
                "x": 0,
                "y": 0,
                "w": environment.width,
                "h": environment.height,
            }
            pos = {
                "x": 0,
                "y": 0,
            }
            environment.drawBackground(@background, rect, pos)
            rect = {
                "x": 0,
                "y": 0,
                "w": environment.constants.MENU_BUTTONS_WIDTH,
                "h": environment.constants.MENU_BUTTONS_HEIGHT,
            }
            pos = {
                "x": environment.constants.MENU_BUTTONS_POS.x,
                "y": environment.constants.MENU_BUTTONS_POS.y,
            }
            environment.drawBackground(@buttons, rect, pos)
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
                        environment.loading = true
