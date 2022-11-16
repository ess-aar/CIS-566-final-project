# Fantasy Map Generator

**University of Pennsylvania CIS 566 Fall 2022, Final Project**
* Megan Reddy, Nick Moon, and Sakshi Rathore

### Design Document

#### Introduction
Many fantasy books, movies, and games include a hand-drawn map describing the features of the fictional world. The art style is often influenced by historic medieval cartographic practices and the author's own vision. We would like to develop a tool for visualizing and creating these maps procedurally. We want to allow users to be able to envision their own world by defining key landmarks and autogenerating the rest of the world automatically in a way that is stylistically and artistically cohesive and similar to these much beloved fantasy maps.

#### Goal
We intend to produce a 2D hexagonal fantasy map generator using Wave Function Collapse in the Unity game engine. We plan to render our procedurally generated map data in the style of the references below.

#### Inspiration/reference:

<details>
  <summary>Fantasy Map Reference Images</summary>
  
  ![mistborn_greyscale](https://user-images.githubusercontent.com/43520504/200185466-631fa337-4e37-46a8-90e8-587224125730.jpg)

  [Mistborn Map](https://www.deviantart.com/mapeffects/art/Mistborn-The-Final-Empire-Map-Brandon-Sanderson-907741466)

  ![lotr_map](https://user-images.githubusercontent.com/43520504/200185526-67683e39-83b9-4daa-bfd2-70f2a17cb18e.jpg)

  [Lord of the Rings Map](https://i.ebayimg.com/images/g/05MAAOSws9dfjJnE/s-l1600.jpg) 

  ![narniamap](https://user-images.githubusercontent.com/43520504/200185636-b325b0bd-319d-4acb-a030-ee172c081eef.jpg)

  [Narnia Map](https://m.media-amazon.com/images/I/91F8R4qQHML.jpg)

  ![landandsea](https://user-images.githubusercontent.com/43520504/200185530-1856d75e-7f1a-4d29-b72a-c06fbbf1adf4.jpg)

  [Land and Sea Board Game](https://www.theboardgamefamily.com/wp-content/uploads/2021/09/20210923_172855.jpg)
</details>

<details>
  <summary>Fantasy Map Generators</summary>
  
  <img width="775" alt="inkarnate" src="https://user-images.githubusercontent.com/43520504/200187904-54a2d224-854f-4b9d-ac64-374e3461be02.PNG">

  [Inkarnate Fantasy Map Creator](https://inkarnate.com/)

  <img width="1280" alt="azgaar" src="https://user-images.githubusercontent.com/43520504/200187977-09de9537-ee70-48bf-bfeb-5bf88cb301ae.PNG">

  [Azgaar's Fantasy Map Generator](https://azgaar.github.io/Fantasy-Map-Generator/)

  <img width="1170" alt="rollforfantasy" src="https://user-images.githubusercontent.com/43520504/200188159-2223faca-f2ce-4088-9382-e23b5abe791c.PNG">

  [Roll For Fantasy Randomized Tile-based Map Generator](https://rollforfantasy.com/tools/map-creator.php)
</details>

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
  - Basic Asset Creation (i.e. basic combination of sea, shore, and land tiles)
  - Creation of hexagonal grid and tiles
  - 2D Hexagonal Wave Function Collapse development
- Megan
  - Shade based on color map from 2D hexagonal tiles in Unity
  - Initial prototype of NPR post-process techniques in Unity
  - Research and prototype how to represent advanced features on tiles (mountains, forests, etc.)

Milestone 2:
- Everyone
  - Polish leftover features from the previous milestone
  - Asset creation and polish (more advanced terrain and sea features such as mountain ranges, forests, lakes, castles, etc.)
- Nick
  - More post-processing filters (roads, rivers, labels, compass, etc.)
- Sakshi
  - UI features and tooling - clear canvas, regeneration of map, and inventory to select tiles
- Megan
  - Continue working on shaders for extra features (mountains, forests, lakes, antique painterly look, etc.)
- If time permits
  - Inifinite map generation :O
  - Extra shader types (e.g. Lord of the Rings or Narnia style)

Final Submission:
- Everyone
  - Polish leftover features from the previous milestones
  - Polish assets and add any extra visual features
  - Finish UI
  - Look into ways to publish project online (live demo)
  - Finalize README and presentation


### Milestone 1

#### Progress


#### Output

<details>
  <summary><b>Basic assets</b></summary>
  <p>3 features - land, water, mountains</p>
  <img src="/img/basic_assets.png">
</details>

<details>
  <summary><b>Wavefunction Collapse</b></summary>
  <br><p>Step 1 - Filling hex grid with random tiles</p>
  <img src="/img/step1.PNG">
  
  <br><p>Step 2 - Filling grid using wavefunction collapse</p>
  <img src="/img/step2.PNG">
  
  <br><p>Step 3 - Added rotation to the tiles to fill the whole grid</p>
  <img src="/img/step3.PNG">
  
  <br><p>Step 4 - Introduced a new feature (mountains)</p>
  <img src="/img/step4.PNG">
</details>

