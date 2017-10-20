$(document).ready(function(){

	var imgPath = "images_color/ciseaux.png";
	div = createDiv(imgPath);
	console.log(div);

//	var initialRotation = 0;
//	$('#b').css({"filter": "blur(1px)"})
//	animateDiv($('#b'), initialRotation);
//	animateDiv($('#c'), initialRotation);
});

function createDiv(imgPath) {
	var imgLoader = new Image(); // create a new image object
	imgLoader.onload = function() { // assign onload handler
		var height = imgLoader.height;
		var width = imgLoader.width;
		$("body").append("<div></div>");
		var div = $("body > div:last"); // select last div created in body
		div.css("background-image", "url("+imgPath+")");
		div.css("background-size", "contain");
		div.css("background-repeat", "no-repeat");
		div.width(width).height(height);
		return div;
	}
	imgLoader.src = imgPath; // set the image source
}

function animateDiv(element, rotation){
	var oldPosition = element.offset();
	var newPosition = makeNewPosition(element);
	var speed = calcSpeed([oldPosition.top, oldPosition.left], newPosition);
	element.animate(
		{ 	top: newPosition[0], left: newPosition[1] }, // destination point
		{ 	duration: speed,
			step: function(){
				rotation += Math.random() - 0.5; // choose a random rotation degree to add, between -0,5 and 0,5
				element.css({'transform' : 'rotate('+ rotation +'deg)'});
			},
			complete: function(){
				animateDiv(element, rotation);        
			}
		}
	);
};

function makeNewPosition(element){
	// Get viewport dimensions (remove the dimension of the div)
	var h = $(window).height() - element.height();
	var w = $(window).width() - element.width();
	var nh = Math.floor(Math.random() * h);
	var nw = Math.floor(Math.random() * w);
	return [nh,nw];    
}

function calcSpeed(prev, next) {
	var x = Math.abs(prev[1] - next[1]);
	var y = Math.abs(prev[0] - next[0]);
	var greatest = x > y ? x : y;
	var speedModifier = 0.03;
	var speed = Math.ceil(greatest/speedModifier);
	return speed;
}