# Game Basic Information

## Summary

`text here`

## Gameplay Explanation

`text here`

# Main Roles

- Producer: [Carlos Huang](https://github.com/cahuang10)
- Movement and Physics: [Karim Shami](https://github.com/BoiPlex)
- Game Logic: [Jason Zhou](https://github.com/khromeengine)
- User interface and input: [Patrick Le](https://github.com/patple)
- Animation and Visuals: [Raghav Bajoria](https://github.com/RaghavsScarletSplendour)

## Producer
Carlos Huang

`text here`

## Movement and Physics
Karim Shami

`text here`

## Game Logic
Jason Zhou

`text here`

## User interface and input
Patrick Le

### Main Menu

The main menu was the first thing I inplemented when doing the UI. The script `menu_manager.gd` organized and manages the whole menu system for our game. In there every menu state is declared as a enum and handles key features such as changing and entering between menus. Futhermore an addon was used to manage the multiple mene scenes. Helpful functions such as `change_scene` allowed us to effortlessly move between menu states while also adding animated transitions. The structure of each menu scene has similar formatting with each other. Being some form of vbox container with a set of buttons, each with their own signal controlled by a script for that scene. Within each menu, besides the start and quit, there is a back button which takes the player to last previous menu. Also each menu has an animated background, this was done by using a TextureRect and creating a shader to automatically scroll the texture, giving it an animated look.

### Pause Menu

For the pause menu it was similarity built like the main menu, however it is not managed by the `menu_manager.gd`. The 3 buttons that make up the pause menu are resume, restart, and quit. Using `paused` boolen that is already in godot I can can make a simple function that pauses the current scene. The pause menu is binded to the escape key so upon pressing it the current screne will be paused and the menu will be made visible. If the player chooses to resume the scene will be unpaused and the game will continue. For the restart button the game is unpaused and the current scene is reloaded thus resetting any progress done. As for the quit, it will take the player back to main menu. For the blured background of the pause menu a ColorRect was used with a shader to give the blured effect.

## Animation and Visuals
Raghav Bajoria

`text here`

# Sub-Roles

- Press Kit and Trailer: [Carlos Huang](https://github.com/cahuang10)
- Narrative Design: [Karim Shami](https://github.com/BoiPlex)
- Audio: [Raghav Bajoria](https://github.com/RaghavsScarletSplendour)
- Gameplay testing / Level Design: [Patrick Le](https://github.com/patple)
- Game Feel & Polish: [Jason Zhou](https://github.com/khromeengine)

## Press Kit and Trailer
Carlos Huang

`text here`

## Narrative Design
Karim Shami

`text here`

## Audio
Raghav Bajoria

`text here`

## Gameplay testing / Level Design
Patrick Le

`text here`

## Game Feel & Polish
Jason Zhou

`text here`
