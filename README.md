# Animated background in JS


## Dependencies

This script needs Velocity to work.

## Getting Started

Place your images in the "images" folder. Prefer very small GIF or PNG image files. Edit the `config.json` configuration file accordingly, which should be placed in the same folder as the script.

Finally, call the script:
```html
<script type="module" src="main.js"></script>
```

Finally, place an empty HTML wrapper with the id `animated-background-wrapper` in your HTML, outside of your content:
```html
<div id="animated-background-wrapper"></div>
```

## Format and lint code with Biome

Lint AND format with:
```bash
npx @biomejs/biome check --apply .
```
