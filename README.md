# Final Project!

This is it! The culmination of your procedural graphics experience this semester. For your final project, we'd like to give you the time and space to explore a topic of your choosing. You may choose any topic you please, so long as you vet the topic and scope with an instructor or TA. We've provided some suggestions below. The scope of your project should be roughly 1.5 homework assignments). To help structure your time, we're breaking down the project into 4 milestones:

## Project planning: Design Doc (due 11/9)
Before submitting your first milestone, _you must get your project idea and scope approved by Rachel, Adam or a TA._

### Design Doc

#### Introduction
Many fantasy books, movies, and games include a hand-drawn map describing the features of the fictional world. The art style is often influenced by historic medieval cartographic practices and the author's own vision. We would like to develop a tool for visualizing and creating these maps procedurally. We want to allow users to be able to envision their own world by defining key landmarks and autogenerating the rest of the world automatically in a way that is stylistically and artistically cohesive and similar to these much beloved fantasy maps.

#### Goal
We intend to produce a 2D hexagonal fantasy map generator using Wave Function Collapse in the Unity game engine. We plan to render our procedurally generated map data in the style of the references below.

#### Inspiration/reference:
![mistborn_greyscale](https://user-images.githubusercontent.com/43520504/200185466-631fa337-4e37-46a8-90e8-587224125730.jpg)

[Mistborn Map](https://www.deviantart.com/mapeffects/art/Mistborn-The-Final-Empire-Map-Brandon-Sanderson-907741466)

![lotr_map](https://user-images.githubusercontent.com/43520504/200185526-67683e39-83b9-4daa-bfd2-70f2a17cb18e.jpg)

[Lord of the Rings Map](https://i.ebayimg.com/images/g/05MAAOSws9dfjJnE/s-l1600.jpg) 

![narniamap](https://user-images.githubusercontent.com/43520504/200185636-b325b0bd-319d-4acb-a030-ee172c081eef.jpg)

[Narnia Map](https://m.media-amazon.com/images/I/91F8R4qQHML.jpg)

![landandsea](https://user-images.githubusercontent.com/43520504/200185530-1856d75e-7f1a-4d29-b72a-c06fbbf1adf4.jpg)

[Land and Sea Board Game](https://www.theboardgamefamily.com/wp-content/uploads/2021/09/20210923_172855.jpg)

<img width="775" alt="inkarnate" src="https://user-images.githubusercontent.com/43520504/200187904-54a2d224-854f-4b9d-ac64-374e3461be02.PNG">

[Inkarnate Fantasy Map Creator](https://inkarnate.com/)

<img width="1280" alt="azgaar" src="https://user-images.githubusercontent.com/43520504/200187977-09de9537-ee70-48bf-bfeb-5bf88cb301ae.PNG">

[Azgaar's Fantasy Map Generator](https://azgaar.github.io/Fantasy-Map-Generator/)

<img width="1170" alt="rollforfantasy" src="https://user-images.githubusercontent.com/43520504/200188159-2223faca-f2ce-4088-9382-e23b5abe791c.PNG">

[Roll For Fantasy Randomized Tile-based Map Generator](https://rollforfantasy.com/tools/map-creator.php)

#### Specification:
- 2D Wave Function Collapse: Implementation of the Wave Function Collapse algorithm
- Hexagonal Tiles: Use hexagonal tiles for the WFC map generation
- Non-photorealistic Rendering: Rendering of assets using shaders that provide features like cross-hatching, paint splotches, and outline generation
- Interactivity: Manual seed placement or autoregeneration of map

#### Techniques:
- 2D Hexagonal Grid made up of 6-sided tiles with a map terrain feature type on each edge of a tile. Each tile has a color mask that defines the feature types that can occupy the tile over its domain.
- Wave Function Collapse to place tiles in the grid based on rules that define what tiles edges can be placed together (i.e. we will only connect two tiles if the
neighboring edge is the same feature type like water).
- For rendering, we plan to use common NPR concepts such as cross-hatching, paint splotches, and outline generation. We will most likely write these as Unity shaders. Additionally, we may add post-process render passes for adding rivers, roads, labels, compass, torn edges, and sea monsters.
- Unity built-in modules for cursor-based selection and GUI rendering

#### Design:

<img width="482" alt="PG Project Flow Diagram" src="https://user-images.githubusercontent.com/90112787/200188201-6eef1f37-ee3b-49e3-89b8-66b1a7b93501.png">

#### Timeline:
Milestone 1:
- Everyone
  - Learn Unity scripting and shading
  - Understand and design approach to Wave Function Collapse Algorithm
- Nick & Sakshi
  - Basic Asset Creation
  - 2D Hexagonal Wave Function Collapse development
- Megan
  - Shade based on color map from 2D hexagonal tiles
  - Initial prototype of NPR techniques

Milestone 2:
- Everyone
  - Polish leftover features from the previous milestone
  - Asset creation and polish
- Nick
  - Post-processing filters
- Sakshi
  - Post-processing labels and roads
- Megan
  - Interactivity
  - Surface shader polish
- If time permits
  - Inifinite map generation :O

Final Submission:
- Everyone
  - Polish leftover features from the previous milestones
  - Asset creation and polish
- Nick
  - Hi
- Sakshi
  - Hi
- Megan
  - Hi

Submit your Design doc as usual via pull request against this repository.
## Milestone 1: Implementation part 1 (due 11/16)
Begin implementing your engine! Don't worry too much about polish or parameter tuning -- this week is about getting together the bulk of your generator implemented. By the end of the week, even if your visuals are crude, the majority of your generator's functionality should be done.

Put all your code in your forked repository.

Submission: Add a new section to your README titled: Milestone #1, which should include
- written description of progress on your project goals. If you haven't hit all your goals, what's giving you trouble?
- Examples of your generators output so far
We'll check your repository for updates. No need to create a new pull request.
## Milestone 3: Implementation part 2 (due 11/28)
We're over halfway there! This week should be about fixing bugs and extending the core of your generator. Make sure by the end of this week _your generator works and is feature complete._ Any core engine features that don't make it in this week should be cut! Don't worry if you haven't managed to exactly hit your goals. We're more interested in seeing proof of your development effort than knowing your planned everything perfectly. 

Put all your code in your forked repository.

Submission: Add a new section to your README titled: Milestone #3, which should include
- written description of progress on your project goals. If you haven't hit all your goals, what did you have to cut and why? 
- Detailed output from your generator, images, video, etc.
We'll check your repository for updates. No need to create a new pull request.

Come to class on the due date with a WORKING COPY of your project. We'll be spending time in class critiquing and reviewing your work so far.

## Final submission (due 12/5)
Time to polish! Spen this last week of your project using your generator to produce beautiful output. Add textures, tune parameters, play with colors, play with camera animation. Take the feedback from class critques and use it to take your project to the next level.

Submission:
- Push all your code / files to your repository
- Come to class ready to present your finished project
- Update your README with two sections 
  - final results with images and a live demo if possible
  - post mortem: how did your project go overall? Did you accomplish your goals? Did you have to pivot?

## Topic Suggestions

### Create a generator in Houdini

### A CLASSIC 4K DEMO
- In the spirit of the demo scene, create an animation that fits into a 4k executable that runs in real-time. Feel free to take inspiration from the many existing demos. Focus on efficiency and elegance in your implementation.
- Example: 
  - [cdak by Quite & orange](https://www.youtube.com/watch?v=RCh3Q08HMfs&list=PLA5E2FF8E143DA58C)

### A RE-IMPLEMENTATION
- Take an academic paper or other pre-existing project and implement it, or a portion of it.
- Examples:
  - [2D Wavefunction Collapse Pokémon Town](https://gurtd.github.io/566-final-project/)
  - [3D Wavefunction Collapse Dungeon Generator](https://github.com/whaoran0718/3dDungeonGeneration)
  - [Reaction Diffusion](https://github.com/charlesliwang/Reaction-Diffusion)
  - [WebGL Erosion](https://github.com/LanLou123/Webgl-Erosion)
  - [Particle Waterfall](https://github.com/chloele33/particle-waterfall)
  - [Voxelized Bread](https://github.com/ChiantiYZY/566-final)

### A FORGERY
Taking inspiration from a particular natural phenomenon or distinctive set of visuals, implement a detailed, procedural recreation of that aesthetic. This includes modeling, texturing and object placement within your scene. Does not need to be real-time. Focus on detail and visual accuracy in your implementation.
- Examples:
  - [The Shrines](https://github.com/byumjin/The-Shrines)
  - [Watercolor Shader](https://github.com/gracelgilbert/watercolor-stylization)
  - [Sunset Beach](https://github.com/HanmingZhang/homework-final)
  - [Sky Whales](https://github.com/WanruZhao/CIS566FinalProject)
  - [Snail](https://www.shadertoy.com/view/ld3Gz2)
  - [Journey](https://www.shadertoy.com/view/ldlcRf)
  - [Big Hero 6 Wormhole](https://2.bp.blogspot.com/-R-6AN2cWjwg/VTyIzIQSQfI/AAAAAAAABLA/GC0yzzz4wHw/s1600/big-hero-6-disneyscreencaps.com-10092.jpg)

### A GAME LEVEL
- Like generations of game makers before us, create a game which generates an navigable environment (eg. a roguelike dungeon, platforms) and some sort of goal or conflict (eg. enemy agents to avoid or items to collect). Aim to create an experience that will challenge players and vary noticeably in different playthroughs, whether that means procedural dungeon generation, careful resource management or an interesting AI model. Focus on designing a system that is capable of generating complex challenges and goals.
- Examples:
  - [Rhythm-based Mario Platformer](https://github.com/sgalban/platformer-gen-2D)
  - [Pokémon Ice Puzzle Generator](https://github.com/jwang5675/Ice-Puzzle-Generator)
  - [Abstract Exploratory Game](https://github.com/MauKMu/procedural-final-project)
  - [Tiny Wings](https://github.com/irovira/TinyWings)
  - Spore
  - Dwarf Fortress
  - Minecraft
  - Rogue

### AN ANIMATED ENVIRONMENT / MUSIC VISUALIZER
- Create an environment full of interactive procedural animation. The goal of this project is to create an environment that feels responsive and alive. Whether or not animations are musically-driven, sound should be an important component. Focus on user interactions, motion design and experimental interfaces.
- Examples:
  - [The Darkside](https://github.com/morganherrmann/thedarkside)
  - [Music Visualizer](https://yuruwang.github.io/MusicVisualizer/)
  - [Abstract Mesh Animation](https://github.com/mgriley/cis566_finalproj)
  - [Panoramical](https://www.youtube.com/watch?v=gBTTMNFXHTk)
  - [Bound](https://www.youtube.com/watch?v=aE37l6RvF-c)

### YOUR OWN PROPOSAL
- You are of course welcome to propose your own topic . Regardless of what you choose, you and your team must research your topic and relevant techniques and come up with a detailed plan of execution. You will meet with some subset of the procedural staff before starting implementation for approval.
