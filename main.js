$(document).ready(function(){
	config.forEach((item) => {
		console.log(item.imgPath);
		createDiv(item.imgPath);
	})
});

//function createDiv2(imgPath) {
//	$("body").append("<div></div>");
//	var div = $("body > div:last"); // select last div created in body
//	div.css("background-image", "url("+imgPath+")");
//	div.css("background-size", "contain");
//	div.css("background-repeat", "no-repeat");
//	return div;
//}

function createDiv(imgPath) {
	var imgLoader = new Image(); // create a new image object
	imgLoader.onload = function() { // assign onload handler
		var height = imgLoader.height;
		var width = imgLoader.width;
		$("#wrapper").append("<div id='d'></div>");
		var div = $("#wrapper > div:last"); // select last div created in body
		div.css("background-image", "url("+imgPath+")");
		div.css("background-size", "contain");
		div.css("background-repeat", "no-repeat");
		div.css("position", "fixed");
		div.width(width).height(height);
		var initialPosition = makeNewPosition(div);	
		div.css({top: initialPosition[1], left: initialPosition[0]});
		var initialAngle = Math.floor(Math.random() * 360) + 1;
		animateDiv(div, initialAngle);
	}
	imgLoader.src = imgPath; // set the image source
}

function animateDiv(element, rotation){
	var oldPosition = element.offset();
	var newPosition = makeNewPosition(element);
	var speed = calcSpeed([oldPosition.top, oldPosition.left], newPosition);
	element.animate(
		{ 	left: newPosition[0],top: newPosition[1] }, // destination point
		{ 	duration: speed,
			step: function(){
				rotation += Math.random() - 0.5; // choose a random rotation degree to add, between -0,5 and 0,5
				//element.css()
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
	var w = $(window).width() - element.width();
	var h = $(window).height() - element.height();
	var nw = Math.floor(Math.random() * w);
	var nh = Math.floor(Math.random() * h);
	return [nw,nh];    
}

function calcSpeed(prev, next) {
	var x = Math.abs(prev[1] - next[1]);
	var y = Math.abs(prev[0] - next[0]);
	var greatest = x > y ? x : y;
	var speedModifier = 0.05;
	var speed = Math.ceil(greatest/speedModifier);
	return speed;
}