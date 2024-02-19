# Animated background in JS


## Dependencies

This script needs Velocity to work, so you have to call those from your HTML page, like that (this versions works, newer have not been tested):
```html
<script src="//cdnjs.cloudflare.com/ajax/libs/velocity/2.0.3/velocity.min.js"></script>
```

## Getting Started

Place your images in the `images` folder. Prefer very small GIF or PNG image files.

Configuration is to be made in a JSON file following the example config file `config.json` with the right paths to your images.
The configuration file needs to be called from the HTML page after JQuery and Velocity:

```html
<script src="config.js"></script>
```
And finally, call the script:

```html
<script src='animated_background.js'></script>
```

Then place the HTML wrapper `<div id="animated-background-wrapper"></div>`in your HTML body, and you're done!
