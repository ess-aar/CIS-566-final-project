# Fantasy Map Generator

**University of Pennsylvania CIS 566 Fall 2022, Final Project**
* Megan Reddy, Nick Moon, and Sakshi Rathore

## Design Document

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


## Milestone 1

#### Progress & Outputs

<details>
  <summary><b>Basic assets</b></summary>
  <p>We started the project with basic assets that are hexagonal textures. Any edge of a tile may be associated with just one feature. Each feature on a tile is identifiable by a color. The idea is that these textures define the space that any feature encompasses on a tile, and not the end look( which would be achieved in post-processing).
  <br>Initially we had just 2 features - land & water. There are tiles for each feature with all edges belonging to that same feature, and there are 5 tiles for any 2 features that interface with eachother. Later on we added mountains (as you will see below). We ended up with 13 tiles in all. <br>
  3 features - land(green), water(blue), mountains(brown)</p>
  <img src="/img/basic_assets.png">
</details>

<details>
  <summary><b>Hexagonal Grid and Tiles</b></summary>
  
  <p><b>Tile</b><br>
  A Tile is a pointed hexagon prefab that has a texture applied to it. Every Tile stores the edge map specific to that tile. An edge map stores which feature each edge maps to and is generated procedurally at run time using texture lookup.</p>
  
  <p><b>Cell</b><br>
  A Cell is a placeholder for a Tile in the grid. A Cell also stores information to aid the Wave Function Collapse algorithm such as, whether the cell collasped, list of compatible tiles that could fill the cell, index of the cell in the grid, etc.</p>
  
  <p><b>Grid</b><br>
  We setup a grid in Unity composed of Cells. Every other row of Cells is offset in order to properly tesselate the hexagon grid pattern. The grid also holds values used in the Wave Function Collapse algorithm like, number of cells collapsed and functions that access or modify multiple cells.</p>
  
  <p>Creating a grid and filling it with random tiles</p>
  <img src="/img/step1.PNG">
  
  <p>
    Some references we used: 
    <a href="https://catlikecoding.com/unity/tutorials/hex-map/part-1/">Catlike Coding Hex Grid</a>, 
    <a href="https://www.redblobgames.com/grids/hexagons/">Red Blob Games Hexagonal Grid</a>
  </p>
</details>

<details>
  <summary><b>Wave Function Collapse</b></summary>
  
  <p><h3>Some terminology</h3>
  <b>Entropy</b>: Entropy of a cell is the total number of tiles that could be placed in the cell, while maintaining the neighboring cells' constraints. The available tiles start as all the tiles. As cells collapse, the entropy starts to decrease and incompatible tiles are removed from the available tiles list.
  <br><br><b>Collapse</b>: A cell is collapsed if it contains an instance of a tile. The goal is to collapse all cells. Thus, once a cell is collapsed, its entropy is set to a very large value so that it does not impact the search for cells with minimum entropy.
  <br><br><b>Propagate Entropy</b>: This happens after a cell collapses. As part of propagate, we update the avaiable tiles list for each neighboring cell of the collapsed cell. Once the tile list is updated, the cell's entropy is updated to the size of the tile list.
  </p>
  
  <p><h3>Wave Function Collapse Steps</h3>
  <b>Generate Seeds</b><br>
  We start with placing random seeds on the grid, i.e. collapse some random cells with random tiles. Then we propogate the entropy from the seeds.</p>
  <p><b>Main loop</b>
  <br>- Get cells with minimun entropy.
  <br>- For each of those cells, pick a random tile from the list of available compatible tiles.
  <br>- Collpase the cell with the picked tile.
  <br>- Propagate entropy accross the grid.
  <br>- Break if all cells are collapsed.
  </p>
  
  <p>This is a grid filled with the inital 7 tiles using the Wave Function Collapse Algorithm. Number of seeds = 5</p>
  <img src="/img/step2.PNG">
  
  <br><p>This output is after we added procedural rotation to the 7 inital tiles (resulting in 42 total tiles). Number of seeds = 10</p>
  <img src="/img/step3.PNG">
  
  <br><p>We wanted to extend the implementation to more features, so we introduced mountain tiles. For this we just added 7 new textures and prefabs, and a new feature color value in the lookup.</p>
  <img src="/img/step4.PNG">
  
  <p><h3>Observations & Next steps</h3></p>
  <p>During this process we noticed some holes appearing in our output. Upon analysis we noticed the following 2 possible enhacements to get rid of these artifacts:
  <br>- Added more assets for special cases like rivers, etc.
  <br>- Adding backtracking to our WFC implementation to avoid a case where a cell has no possible tile it could pick.
  </p>
  
  <p>Another feature step we would like to implement is adding probability to our features & tiles. We noticed the output right now is more or less a uniform distribution of each feature. As this is undesireable for the look we want, adding varied probability should help us get larger landmasses and oceans.</p>
</details>

<details>
  <summary><b>Rendering Prototype</b></summary>
  <br><p>The rendering work for this milestone can be found in the "Milestone_1_Rendering" branch. The basic rendering process consists of three passes to get the desired output. Although the order of these passes may change, the current sequence is:
  <br>
  <br>1. Color pass
  <br>2. Asset pass
  <br>3. Edge/Outline pass
  <br>
  <br>The Wave Function Collapse algorithm will output a grid with colored hexagonal tiles. Each color serves as an ID representing distinct terrain features such as land, water, mountains, forests, etc. The color pass will take these ID colors and map them to the desired output color for that feature. The asset pass will scatter assets in designated areas according to color (e.g. a brown area indicates mountains in which several mountains will be scattered). The outline pass will draw outlines around each feature. </p>
  <details>
    <summary><b>Unity Setup</b></summary>
    <br>
    <p><b>Step 1.</b> Create basic grid setup and camera for rendering</p>
    <p>I started by creating a new Unity project so that I could test out rendering techniques without affecting the main Wave Function Collapse project. Using the basic assets (tiles) we created, I manually placed and constructed a hexagon grid for testing the post-process effects. Since the post-process effects would operate on a camera, I created a new Orthographic camera called "Top Down Camera" so that I could attach any scripts and shaders I made to it.</p>
    <img src="/img/unity_camera_setup.PNG">
    <br>
    <br>
    <p><b>Step 2.</b> Create post-process script and setup color pass shader</p>
    <p>In order to apply a post-process effect to the camera image, I needed a script that would tell the camera to pass the output image through a shader before rendering the result to the screen. To do this, I made a very simple script that sends the camera output to a shader, and then sends the result to the screen. To see if this worked, I created a new shader that would take the base color of the tiles and apply FBM to it.</p>
    <img src="/img/unity_color_pass_only.PNG">
    <br>
    <br>
    <p><b>Step 3.</b> Create edge/outline shader</p>
    <p>Now that one shader was setup, I added another shader to test outlines. I created a basic Sobel filter that would create outlines based on color differences within an image.</p>
    <img src="/img/unity_edge_pass_only.PNG">
    <br>
    <br>
    <p><b>Step 4.</b> Execute both shaders at the same time</p>
    <p>After I got each individual shader working, I tested them together. Each shader is executed sequentially and uses the output of the previous shader as its input. In this case, the output of the color pass will be used as the input to the edge pass. This was a critical step because our pipeline depends on the ability to execute multiple passes at once. The look of the Unity shaders will be refined more in the following milestone, but the infrastructure is in place to handle multiple effects at once.</p>
    <img src="/img/unity_prototype.PNG">
  </details>
  <details>
    <summary><b>Shadertoy Prototype</b></summary>
    <br><p>I made a Shadertoy prototype to further experiment with different looks and algorithms without worrying about the Unity shader interface. I mimicked the shader pipeline that I had setup by using different Buffers. The shader can be viewed <a href="https://www.shadertoy.com/view/ddj3Wd">here</a>.</p>
    <br>
    <br>
    <p><b>Step 1.</b> Color output from Wave Function Collapse</p>
    <p>Buffer A outputs a possible result from the Wave Function Collapse algorithm. In our setup, green areas are land, blue areas are sea, and brown areas are mountains. The brown areas are not meant to show up in the final rendering; they are simply a mask to indicate where we should scatter mountain assets.</p>
    <img src="/img/wfc_color_map.PNG">
    <br>
    <br>
    <p><b>Step 2.</b> Grid pass</p>
    <p>In order to randomly place assets within an area, I first split the screen into a uniform grid using fract(GRID_SIZE * uv). I used an approach similar to stratified sampling in path tracing and to the grid layout described in <a href="https://www.youtube.com/watch?v=rvDo9LvfoVE">this Art of Code tutorial</a>. Modifying the grid size will control the density of assets placed in the masked areas.</p>
    <img src="/img/uniform_grid.PNG">
    <br>
    <br>
    <p><b>Step 3.</b> Uniformly sample grid</p>
    <p>To start, I placed one sample in the center of each grid cell. Each of the circles is an SDF, which I am planning to use to procedurally draw the assets for the next milestone.</p>
    <img src="/img/uniform_sampling.PNG">   
    <br>
    <br>
    <p><b>Step 4.</b> Stratified sampling of grid</p>
    <p>Instead of placing the sample in the cell center, I jittered the position using a 1D noise function to create a more organic look.</p>
    <img src="/img/stratified_sampling.PNG"> 
    <br><p>Here is the same result without the grid lines:</p>
    <img src="/img/sample_placement_no_grid.PNG">
    <br>
    <br>
    <p><b>Step 5.</b> Constrain to masked areas</p>
    <p>Now that the samples were randomly placed, I needed to constrain them to the desired areas. I have implemented the naive way of doing this, which simply looks at the base color, decides whether or not it matches the mask color, and places a circle SDF there if it does. I am trying to figure out a more advanced way of doing this, since it cuts off portions of the SDF that lie outside of the mask. The desired output would finish drawing those pieces, even if they are out of bounds. My first solution was to iterate through each cell's neighbors and add the SDF contribution from the neighboring cells. This worked, but when I added the mask back in, the cutoff problem persisted.</p>
    <img src="/img/constrained_asset_placement.PNG">
    <br>
    <br>
    <p><b>Step 6.</b> Coloring and outlines</p>
    <p>Here are some example outputs with more interesting coloring and outlines. The color and outline passes are the same as the ones in Unity. The main difference is that this outline pass operates on a greyscale version of the image, to create black outlines instead of colored outlines. 

In the next milestone, these circles will be replaced with more advanced assets and shapes that represent actual terrain features.</p>
    <img src="/img/color_map_asset_mask.PNG">
    <img src="/img/colored_map_no_mask.PNG">
  </details>
  
  <p><b>Observations & Next steps</b></p>
  <p>For the next milestone, I will first focus on porting the Shadertoy prototype to my Unity setup. Then, I will work on refining each of the post-process effects and asset drawings. This includes creating SDFs for mountains, forests, and a compass, as well as refining the color and edge passes to include more effects from our reference images. Some effects I hope to incorporate are the burnt-edge look, the hatching next to coastlines, and an erosion effect to create a smudged/painterly paper look. 
  </p>
</details>



## Milestone 2

#### Progress & Outputs

<details>
  <summary><b>Assets</b></summary>
  <p>In this milestone we added another feature for forests, which interfaces with the land feature only (much like the mountain feature).
  <br>We also changed the colors we used for our textures to use colors that were as distinct from each other as possible, to avoid artifacts in the post-process rendering steps.
  <br>4 features - land(green), water(blue), mountains(red), forests(yellow)</p>
  <br><img src="/img/basic_assets_2.png">
</details>

<details>
  <summary><b>Wave Function Collapse</b></summary>
  
  <p><h3>Backtracking</h3>
  As mentioned in the observations and outputs of Milestone 1, we were seeing some scenarios where we end up with holes. To avoid this, we implemented a simple backtracking method that checks ahead for one level of propagation before making a decision. This method seems to works for majority of the scenarios.
  </p>
  
  <p><b>WFC logic with backtracking:</b>
  <br>- Get cells with minimun entropy.
  <br>- For each of those cells, pick a random tile from the list of available compatible tiles.
  <br>- <b>Before collapsing the cell, check if using the picked tile will make any of the neighboring cells' entropy 0<b>.
  <br>- If yes, pick a different random tile from the list of available compatible tiles.
  <br>- If no, collpase the cell with the picked tile.
  <br>- Propagate entropy accross the grid.
  <br>- Break if all cells are collapsed or if we've retried picking a random tile a certain number of times.
  </p>
  
  <p>Output with backtracking, 4 features and randomly generated seeds. Number of seeds = 5</p>
  <img src="/img/step7.png">
  
  <p><h3>Observations & Next steps</h3></p>
  <p>Our current backtracking solution still doesn't solve all problems and we do sometimes end up with an uncollapsable grid. This happens in situations where there is a need for a tile that does not exist (e.g., a tile with both mountain and forest edges). We do not intend to fix this by adding the "missing" tile assets, as we do not want to such interfacing between features to exist on the map.
    <br>We plan to use a brute force solution to get by this issue, for example - placing a tile (that may not match the constraints) to update the entropy of the grid so that the WFC can resume to collapse the whole grid.
  </p>
  
</details>

<details>
  <summary><b>User Interface</b></summary>
  
  <p><h3>Placing seeds</h3>
  To add some interactivity, we let the user place tiles as seeds for the WFC. The user can use the mouse by <b>clicking & draging</b> to populate the grid cells with tiles of any of the 4 features. The user can cycle through the tiles by clicking on the active seed tile preview on the upper right corner or by pressing <b>tab</b> on the keyboard.
  <br>Once the user is satisfied with the seed placements, they can start the WFC by pressing <b>enter</b> on the keyboard.</p>
  
https://user-images.githubusercontent.com/90112787/204433411-c4f9f59a-9365-4ccc-abc7-859f3f20c5d6.mov

</details>
