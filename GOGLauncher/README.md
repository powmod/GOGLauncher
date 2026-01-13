# GOGLauncher
Rainmeter skin that adds installed games on GOG Galaxy as launchable game images on the desktop. The script automatically detects games in the installed section of your GOG client, including external and manually added games.

## Installation and Usage
After installing [Rainmeter](https://www.rainmeter.net/) download the latest .rmskin file in the releases page and double-click it to install the skin. To set the skin for the first time you need to first launch Update.ini. 
Every time you change a setting or add/remove/change a game in GOG you need to run Update.ini again.
To quickly iterate over the settings simply right-click on one of the grid images, and select Update.ini and GOGLauncher.
To change a game image simply change the image in your GOG Galaxy and run Update.ini.

## Skin settings
Open Rainmeter manager and under the GOGLauncher folder, select and edit the Update.ini file. This file contains the variables necessary to customize the skin:

 - **GOGGalaxyPath**: change the default path to the GalaxyClient.exe if necessary
 - **GalaxyProgramDataPath**: change the path to GOG ProgramData folder if necessary
 - **ImageWidth**, **ImageHeight**: These are the default dimensions of the images that are displayed in GOG. You shouldn't change these unless you're using custom images for all your games, with different dimensions.
 - **CornerRadius**: Radius of the image corners. Set to 0 to display sharp corners.
 - **ImagesPerRow**: Number of columns in your grid. Setting this value to 0 will automatically detect the maximum number of columns that maximizes the size of the images taking into account your current resolution and chosen image spacing.
 - **ImageSpacing**: Space, or padding, between each image in the grid.
 - **Zoom**: Overall size of the grid. Values >1 are possible but this will cause some images to be off screen.
 - **dropShadow**: Change to 0 to disable shadows under the images.
 - **shadowOffset**: Distance of the shadow along the main diagonal of the image.
 - **shadowSize**: size of the shadow mask.
 - **shadowAlpha**: Opacity of the shadow. If you want to disable the shadow set dropShadow to 0 instead of setting this value to 0.
 - **shadowMask**: Choose between shadow.png and shadow1.png. Shadow.png if blurrier and you might need to increase its size to see the shadow. You can also create your own shadow masks and change them here.
 The remaining paths shouldn't need to be changed.

![V1 0_tall_grid](https://github.com/powmod/GOGLauncher/assets/10146681/03178641-6010-4200-951e-0cbbce8cd1b4)
![V1 0_full_grid](https://github.com/powmod/GOGLauncher/assets/10146681/21d7f0ea-740a-433c-8a16-70da446304c4)
