<!DOCTYPE html>
<html lang="fr">

	<head>

	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<style type="text/css">
			#a {
				width: 50px;
				height:50px;
				background-color:red;
				position:fixed;

			}
			#b{
				width: 50px;
				height: 50px;
				background-image: url('images_color/ciseaux.png');
				background-size: contain;
				background-repeat: no-repeat;
				position: fixed;
			}
			#c{
				width: 50px;
				height: 50px;
				background-image: url('images_color/dossier.png');
				background-size: contain;
				background-repeat: no-repeat;
				position: fixed;
			}
		</style>

		<script src="https://code.jquery.com/jquery-3.2.1.min.js"
			integrity="sha256-hwg4gsxgFZhOsEEamdOYGBf13FyQuiTwlAQgxVSNgt4="
			crossorigin="anonymous"></script>
		<script type="text/javascript" src='main.js'></script>
		<script type="text/javascript">
			function debug(data){ 
				console.log(data); 
			}
		</script>

	</head>
	
	<body>

		<!-- <div id="a"></div> -->

		<div id="b"></div>

		<div id="c"></div>

		<!-- <img id="i" src ="images_color/dossier.png" /> -->

	</body>

</html>