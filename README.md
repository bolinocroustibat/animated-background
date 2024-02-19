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
Then you also need to call the main script from your webpage

```html
<script src='animated_background.js'></script>
```

Finally, place an empty HTML wrapper with the id `animated-background-wrapper` in your HTML, outside of your content:
```html
<div id="animated-background-wrapper"></div>
```

You're done!
