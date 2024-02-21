# Animated background in JS


## Dependencies

This script needs the JS module Velocity to work, so since there is no packaging in this project, you have to call it from your HTML page, like that:
```html
<script src="//cdnjs.cloudflare.com/ajax/libs/velocity/2.0.6/velocity.min.js"></script>
```

## Getting Started

Place your images in the `images` folder. Prefer very small GIF or PNG image files.

Configuration is to be made in a JSON file following the example config file `config.json` with the right paths to your images.
The configuration file needs to be called from the HTML page after Velocity is called:

```html
<script src="config.js"></script>
```
Then you also need to call the main script from your webpage

```html
<script src='animated_background.js'></script>
```

Finally, place an empty HTML wrapper with the id `animated-background-wrapper` in your HTML, outside of your content:
```html
<div id="animated-background-wrapper"></div>
```

You're done!
