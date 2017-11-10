Particle Circle
===============

Classes, (arguments to accept):
- Vec2 (x, y) - Abstract class for Vector

- World (canvas) - Main class for frame, methods:
  * start - Starts frame

- _Object (config) - Parent class for all objects in the world, config fields:
  * loc - Vector with coordinates
  And abstract methods:
  * update - To update self coordinates and etc
  * draw - To draw self in frame

- ParticleCircle (config) - Extends _Object. Abstract class for saving all particles, config fields:
  * loc - Vector with coordinates
  * color - Color for the particles, if you pass 'random', you must pass field 'randomColors'
  * randomColors - array with strings with colors
  * velocity - speed of particles
  * particleAmount - amount of particles
  * particleRadius - radius of particles

- Particle (config) - Extends _Object.