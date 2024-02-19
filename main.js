import Velocity from "velocity-animate"
import "./style.css"

const createDiv = (
	animatedBackgroundWrapper,
	imgPath,
	speed,
	possibleAngle,
	possibleBlur,
) => {
	const imgLoader = new Image() // create a new image object
	imgLoader.onload = () => {
		// assign onload handler
		// Create the div and assign initial style
		const div = document.createElement("div")
		div.style.width = `${imgLoader.width}px`
		div.style.height = `${imgLoader.height}px`
		div.style.backgroundImage = `url(${imgPath})`
		div.style.position = "fixed"
		div.style.top = `${makeNewPosition(div)[1]}px`
		div.style.left = `${makeNewPosition(div)[0]}px`
		const initialRotation = makeNewRotation(possibleAngle)
		div.style.transform = `rotate(${initialRotation}deg)`
		const initialBlur = makeNewBlur(possibleBlur)
		div.style.filter = `blur(${initialBlur}px)`
		// Add the div to the end of the wrapper
		animatedBackgroundWrapper.appendChild(div)
		// Animate the div
		animateDiv(
			div,
			speed,
			initialRotation,
			initialBlur,
			possibleAngle,
			possibleBlur,
		)
	}
	imgLoader.src = imgPath // set the image source
}

const animateDiv = (
	element,
	speed,
	initialRotation,
	initialBlur,
	possibleAngle,
	possibleBlur,
) => {
	const rect = element.getBoundingClientRect()
	const oldPosition = {
		top: rect.top + window.scrollY,
		left: rect.left + window.scrollX,
	}
	const newPosition = makeNewPosition(element)
	const duration = calcDuration(
		[oldPosition.top, oldPosition.left],
		newPosition,
		speed,
	)
	let rotation = initialRotation
	const finalRotation = makeNewRotation(possibleAngle)
	const stepRotation = (finalRotation - rotation) / (duration / 13) // angle to change for each step = total rotations to achieve / number of animation steps
	let blur = initialBlur
	const finalBlur = makeNewBlur(possibleBlur)
	const stepBlur = (finalBlur - blur) / (duration / 13)
	Velocity(
		element,
		{ left: newPosition[0], top: newPosition[1] }, // destination point
		{
			duration: duration,
			step: () => {
				rotation += stepRotation
				element.css({ transform: `rotate(${rotation}deg)` })
				blur += stepBlur
				element.css({ filter: `blur(${blur}px)` })
			},
			complete: () => {
				animateDiv(element, speed, rotation, blur, possibleAngle, possibleBlur)
			},
		},
	)
}

const makeNewPosition = (element) => {
	// Get viewport dimensions (remove the dimension of the div)
	const w = window.innerWidth - parseInt(element.style.width, 10)
	const h = window.innerHeight - parseInt(element.style.height, 10)
	const nw = Math.floor(Math.random() * w)
	const nh = Math.floor(Math.random() * h)
	return [nw, nh]
}

const makeNewRotation = (possibleAngle) => {
	const angle =
		Math.floor(Math.random() * (possibleAngle[1] - possibleAngle[0])) +
		possibleAngle[0]
	return angle
}

const makeNewBlur = (possibleBlur) => {
	const blur =
		Math.floor(Math.random() * (possibleBlur[1] - possibleBlur[0])) +
		possibleBlur[0]
	return blur
}

const calcDuration = (prev, next, speed) => {
	const x = Math.abs(prev[0] - next[0])
	const y = Math.abs(prev[1] - next[1])
	const greatest = x > y ? x : y
	const duration = Math.ceil((greatest / speed) * 100)
	return duration
}

await fetch("config.json")
	.then((response) => response.json())
	.then((data) => {
		let animatedBackgroundWrapper = document.getElementById(
			"animated-background-wrapper",
		)
		for (const item of data.bgConfig) {
			createDiv(
				animatedBackgroundWrapper,
				item.imgPath,
				item.speed,
				item.possibleAngle,
				item.possibleBlur,
			)
		}
	})
