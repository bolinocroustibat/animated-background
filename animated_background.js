$(document).ready(function(){
	bgConfig.forEach((item) => {
		createDiv(item.imgPath, item.speed, item.possibleAngle, item.possibleBlur);
	})
});

function createDiv(imgPath, speed, possibleAngle, possibleBlur) {
	let imgLoader = new Image(); // create a new image object
	imgLoader.onload = function() { // assign onload handler
		let height = imgLoader.height;
		let width = imgLoader.width;
		$("#animated-background-wrapper").append("<div></div>");
		let div = $("#animated-background-wrapper > div:last"); // select last div created in wrapper
		div.width(width).height(height);
		div.css({"background-image": "url("+imgPath+")", "background-size": "contain", "background-repeat": "no-repeat", "position": "fixed"});
		div.css({top: makeNewPosition(div)[1], left: makeNewPosition(div)[0]});
		let initialRotation = makeNewRotation(possibleAngle);
		div.css({'transform' : 'rotate('+ initialRotation +'deg)'});
		let initialBlur = makeNewBlur(possibleBlur);
		div.css({'filter': 'blur('+ blur +'px)'});
		animateDiv(div, speed, initialRotation, initialBlur, possibleAngle, possibleBlur);
	}
	imgLoader.src = imgPath; // set the image source
}

function animateDiv(element, speed, initialRotation, initialBlur, possibleAngle, possibleBlur){
	let oldPosition = element.offset();
	let newPosition = makeNewPosition(element);
	let duration = calcDuration([oldPosition.top, oldPosition.left], newPosition, speed);
	let rotation = initialRotation;
	let finalRotation = makeNewRotation(possibleAngle);
	let stepRotation = (finalRotation-rotation)/(duration/jQuery.fx.interval); // angle to change for each step = total rotation to achieve / number of animation steps
	let blur = initialBlur;
	let finalBlur = makeNewBlur(possibleBlur);
	let stepBlur = (finalBlur-blur)/(duration/jQuery.fx.interval);
	element.velocity(
		{	left: newPosition[0], top: newPosition[1] }, // destination point
		{	duration: duration,
			step: function(){
				rotation += stepRotation;
				element.css({'transform' : 'rotate(' + rotation + 'deg)'});
				blur += stepBlur;
				element.css({'filter': 'blur(' + blur + 'px)'});
			},
			complete: function(){
				animateDiv(element, speed, rotation, blur, possibleAngle, possibleBlur);        
			}
		}
	);
};

// Get viewport dimensions, while removing the dimension of the div
function makeNewPosition(element){
	let w = $(window).width() - element.width();
	let h = $(window).height() - element.height();
	let nw = Math.floor(Math.random() * w);
	let nh = Math.floor(Math.random() * h);
	return [nw,nh];
}

function makeNewRotation(possibleAngle){
	angle = Math.floor(Math.random() * (possibleAngle[1] - possibleAngle[0])) + possibleAngle[0];
	return angle;
}

function makeNewBlur(possibleBlur){
	blur = Math.floor(Math.random() * (possibleBlur[1] - possibleBlur[0])) + possibleBlur[0];
	return blur;
}

function calcDuration(prev, next, speed) {
	let x = Math.abs(prev[0] - next[0]);
	let y = Math.abs(prev[1] - next[1]);
	let greatest = x > y ? x : y;
	let duration = Math.ceil(greatest / speed * 100);
	return duration;
}