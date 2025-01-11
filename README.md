Camping Script for FiveM
Overview
This script allows players to place tents, start campfires, and set up chairs in your FiveM server, adding fun camping features for more immersive roleplay. Players can cook items on the campfire and use the tent’s built-in stash to store gear.

Features
Placeable Tents
Includes a stash for item storage.
Campfires with Cooking
Cook various recipes on the fire.
Camping Chairs
Optimized & Configurable
minimal performance impact.

- Dependancys
  - QBCore
  - ox_lib
  - object_gizmo (https://github.com/Demigod916/object_gizmo)
  - QS-inventory (can be changed)

Installation
  - Drag and drop into your standalone folder
  - Add items provided


Usage
- Use the Tent
   - Players can use the tent item in their inventory.
    This spawns a temporary Gizmo object they can move/rotate.
    Press Enter (default) to confirm placement.
    The tent has an interaction for storing items (stash) and packing it back up.
    
- Use the Campfire
    - Players can use the campfire item in the same way.
      Campfire includes cooking options:
      Players can cook recipes if they have required items.
      They can extinguish the fire and reclaim the item.
      
- Use the Camping Chair
    - Similar to the tent/campfire, players can place a chair.
      Interact to sit down or pack up the chair. (chair sitting script required, it is not built in)
      
- Cooking
    - Interact with the campfire, select “Cook”.
      Choose a recipe if you have the required items.
      Script will remove the required items, start a progress bar, then give the cooked item.

- Recipes
    - Located in config.lua
      Each recipe lists required items, output item, cooking time, etc.
      
- Item Names:
    - Make sure they match those in your inventory system.
      E.g., tent, campfire, campingchair (case-sensitive).


Known Issues / Troubleshooting
 - none

Future Updates
Additional cookable recipes and crafting options.
Optional terrain alignment for tents (if desired).
More advanced camp objects (like sleeping bags, lanterns, etc.).
Support
If you encounter any issues or have suggestions for improvements:

Create an Issue on the GitHub repository.
We appreciate your feedback and contributions!

Happy Camping!
Enjoy the script and have fun adding a wilderness roleplay experience to your FiveM server.












