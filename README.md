# Animated background in JS


## Dependencies

This script need JQuery and Velocity to work, so you have to call those on your webpage, like that (those versions work, newer have not been tested):

```
<script src="//code.jquery.com/jquery-3.2.1.min.js" integrity="sha256-hwg4gsxgFZhOsEEamdOYGBf13FyQuiTwlAQgxVSNgt4=" crossorigin="anonymous"></script>
```

```
<script src="//cdnjs.cloudflare.com/ajax/libs/velocity/2.0.3/velocity.min.js"></script>
```

## Getting Started

Place your images in the "images" folder. Prefer very small GIF or PNG image files. Configuration is to be made in a JSON file, in which you follow the syntax of the example "config_bg_test.json" with the right paths to your images.
Call your configuration file after JQuery and Velocity:

```
<script src="config_bg_test.json"></script>
```
And finally, call the script:

```
<script src='animated_background.js'></script>
```

Then place the HTML wrapper in your HTML body, and you're done!
