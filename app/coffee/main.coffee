class Vec2
  constructor: (x, y) ->
    @x = x ? 0
    @y = y ? 0

  add: (vec) ->
    if arguments[1] isnt undefined
      @x += arguments[0] ? 0
      @y += arguments[1] ? 0
      return @

    @x += vec.x ? 0
    @y += vec.y ? 0
    return @

  copy: ->
    return new Vec2 @x, @y


class World
  constructor: (@canvas) ->
    @_canvasWidth = @canvas.width = window.innerWidth
    @_canvasHeight = @canvas.height = window.innerHeight
    @ctx = @canvas.getContext '2d'

    @_objects = []

  addObject: (constructor, config) ->
    config.world = @
    obj = new constructor config
    @_objects.push obj

  start: ->
    if @_objects.length is 0
      throw new Error 'No objects to draw!'

    do @tick

  tick: ->
    do @update
    do @draw
    requestAnimationFrame @tick.bind @

  update: ->
    do object.update for object in @_objects

  draw: ->
    @ctx.fillStyle = 'rgba(0,0,0,.07)'
    @ctx.fillRect 0, 0, @_canvasWidth, @_canvasHeight
    do object.draw for object in @_objects

  @randomIntBetween: (min, max) ->
    return Math.round do Math.random * (max - min) + min

class _Object
  constructor: (config) ->
    @world = config.world
    @_loc = config.loc ? new Vec2

  update: ->
    throw new Error 'Method must be overriden'

  draw: ->
    throw new Error 'Method muse be overriden'

class ParticleCircle extends _Object
  constructor: (config) ->
    super config
    @randomColors = config.randomColors ? [
      '#2C3E50'
      '#FC4349'
      '#D7DADB'
      '#6DBCDB'
      '#FFFFFF']
    @_color = config.color ? '#fff'
    @_velocity = config.velocity ? .02
    @_particleAmount = config.particleAmount ? 6
    @_particleRadius = config.particleRadius ? 5

    @_particles = []

    do @init

  init: ->
    for i in [0...@_particleAmount]
      @addParticle {
        loc: do @_loc.copy
        radius: @_particleRadius
        color: @_color
        velocity: @_velocity
      }, i

    @world.canvas.addEventListener 'mousemove', @move
    @world.canvas.addEventListener 'wheel', @wheel

  addParticle: (config, ind) ->
    config.particleCircle = @
    @_particles.push new Particle config, ind

  update: ->
    do particle.update for particle in @_particles when particle.updateble

  draw: ->
    do particle.draw for particle in @_particles when particle.updateble

  ##########
  # Events #
  ##########

  move: (e) =>
    particle.move e for particle in @_particles

  wheel: (e) =>
    found = no
    len = @_particles.length - 1
    if e.ctrlKey
      do e.preventDefault
      if e.deltaY > 0
        while not found and @_particles[len]
          if @_particles[len].updateble
            @_particles[len].updateble = no
            found = on
          else len--
        return

      len = 0
      while not found and @_particles[len]
        if @_particles[len].updateble then len++
        else
          @_particles[len].updateble = on
          found = on
      return


    particle.wheel e for particle in @_particles

class Particle extends _Object
  constructor: (config, ind) ->
    super config
    @updateble = on

    @particleCircle = config.particleCircle
    @world = @particleCircle.world
    @_radius = config.radius
    @_velocity = config.velocity / 100
    @_radians = do Math.random * 2 * Math.PI
    @_distanceFromCenter = do Math.random * (125 - 50) + 50
    if config.color is 'random'
      @_color = @particleCircle.randomColors[World.randomIntBetween 0, @particleCircle.randomColors.length]
    else
      @_color = config.color

    ##########
    # Events #
    ##########

    @_initLoc = do config.loc.copy
    @_lastLoc = new Vec2

    @_mouseLoc = do config.loc.copy
    @_lastMouseLoc = do config.loc.copy


  update: ->
    @_lastLoc.x = @_loc.x
    @_lastLoc.y = @_loc.y

    @_lastMouseLoc.x += (@_mouseLoc.x - @_lastMouseLoc.x) * 0.05
    @_lastMouseLoc.y += (@_mouseLoc.y - @_lastMouseLoc.y) * 0.05

    @_radians += @_velocity
    @_loc.x = @_lastMouseLoc.x + Math.cos(@_radians) * @_distanceFromCenter
    @_loc.y = @_lastMouseLoc.y + Math.sin(@_radians) * @_distanceFromCenter

  draw: ->
    do @world.ctx.beginPath

    @world.ctx.strokeStyle = @_color
    @world.ctx.lineWidth = @_radius
    @world.ctx.moveTo @_lastLoc.x, @_lastLoc.y
    @world.ctx.lineTo @_loc.x, @_loc.y
    do @world.ctx.stroke

    do @world.ctx.closePath

  ##########
  # Events #
  ##########

  move: (e) ->
    @_mouseLoc.x = e.offsetX
    @_mouseLoc.y = e.offsetY

    @_initLoc.x = @_mouseLoc.x
    @_initLoc.y = @_mouseLoc.y

  wheel: (e) ->
    if e.deltaY < 0 then @_velocity += 0.01
    else @_velocity -= 0.01



world = new World document.getElementById 'canvas'
world.addObject ParticleCircle, {
  loc: new Vec2 300, 300
  color: 'random'
  particleAmount: 150
  particleRadius: 2
  velocity: 4
}

window.world = world
do world.start