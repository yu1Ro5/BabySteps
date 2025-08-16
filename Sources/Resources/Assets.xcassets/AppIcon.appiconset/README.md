# App Icon Setup

## Required Icon Sizes

This directory contains the app icon configuration for BabySteps iOS app.

### Icon Sizes Needed:

**iPhone:**
- 20x20@2x (40x40px)
- 20x20@3x (60x60px)
- 29x29@2x (58x58px)
- 29x29@3x (87x87px)
- 40x40@2x (80x80px)
- 40x40@3x (120x120px)
- 60x60@2x (120x120px)
- 60x60@3x (180x180px)

**iPad:**
- 20x20@1x (20x20px)
- 20x20@2x (40x40px)
- 29x29@1x (29x29px)
- 29x29@2x (58x58px)
- 40x40@1x (40x40px)
- 40x40@2x (80x80px)
- 76x76@2x (152x152px)
- 83.5x83.5@2x (167x167px)

**App Store:**
- 1024x1024@1x (1024x1024px)

## How to Add Icons

1. Create your app icon image (recommended size: 1024x1024px)
2. Use an icon generator tool (like App Icon Generator) to create all required sizes
3. Replace the placeholder files with actual PNG images
4. Ensure all images are properly named according to the Contents.json specification

## Tools for Icon Generation

- [App Icon Generator](https://appicon.co/)
- [MakeAppIcon](https://makeappicon.com/)
- [Icon Set Creator](https://apps.apple.com/us/app/icon-set-creator/id939343785)

## Notes

- All icons must be PNG format
- Icons should not have transparency
- Icons should not have rounded corners (iOS will automatically round them)
- The 1024x1024 icon is used for the App Store and should be your highest quality version