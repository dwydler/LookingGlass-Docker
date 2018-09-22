<?php
// lazy config check/load
if (file_exists('LookingGlass/Config.php')) {
	require 'LookingGlass/Config.php';
	
	if (!isset($ipv4, $ipv6, $siteName, $siteUrl, $serverLocation, $testFiles, $theme)) {
		exit('Configuration variable/s missing. Please run configure.sh');
	}
}
else {
	exit('Config.php does not exist. Please run configure.sh');
}

// include multi  language sytem
if ( (isset($_GET["lang"])) && (preg_match("/^[a-z]{2}\_[A-Z]{2}$/",$_GET["lang"])) ) {
	$locale = $_GET["lang"];
	setlocale(LC_MESSAGES, $locale);
	bindtextdomain("messages", "./locale");
	textdomain("messages");
	bind_textdomain_codeset("messages", 'UTF-8');
}
else {
	$locale = "en_US";
}
?>

<!DOCTYPE html>
<html lang="en" xml:lang="en">
	<head>
		<meta http-equiv="X-UA-Compatible" content="IE=edge" />
		<meta http-equiv="content-type" content="text/html; charset=utf-8" />
		<meta name="viewport" content="width=device-width, initial-scale=1" />
		<meta name="description" content="LookingGlass - Open source PHP looking glass" />
		<meta name="author" content="Telephone" />
		
		<title><?php echo $siteName; ?></title>

		<!-- Browser-Update.org -->
		<script> 
		var $buoop = {required:{e:-4,f:-3,o:-3,s:-1,c:-3},insecure:true,unsupported:true,api:2018.09 }; 
		
		function $buo_f(){ 
			var e = document.createElement("script"); 
			e.src = "//browser-update.org/update.min.js"; 
			document.body.appendChild(e);
		};

		try {document.addEventListener("DOMContentLoaded", $buo_f,false)}
		catch(e){window.attachEvent("onload", $buo_f)}
		</script>
		
		<!-- Translation for JavaScript -->
		<script>
		RunTest = "<?php echo _("Run Test"); ?>"
		Loading = "<?php echo _("Loading"); ?>"
		</script>
		
		<!-- Styles -->
		<link href="assets/css/<?php echo $theme; ?>" rel="stylesheet" />
	</head>
  
	<body>
		<!-- Container -->
		<div class="container">

			<!-- Header -->
			<div class="row" id="header">
				<div class="col-xs-12">
					<div class="page-header">
						<h1><a id="title" href="<?php echo $siteUrl; ?>?lang=<?php echo $locale;?>"><?php echo $siteName; ?></a></h1>
					</div>
				</div>
			</div>

			<!-- Network Information -->
			<div class="row">
				<div class="col-sm-6">
					<div class="panel panel-default">
						<div class="panel-heading">
							<?php
							echo _("Network information")." ";
							
							if ( (!empty($siteUrlv4)) &&  (!empty($siteUrlv6)) ) {
								echo "( <a href=\"".$siteUrl."?lang=".$locale."\">"._("DualStack")."</a> | 
								        <a href=\"".$siteUrlv4."?lang=".$locale."\">"._("Only IPv4")."</a> |
										<a href=\"".$siteUrlv6."?lang=".$locale."\">"._("Only IPv6")."</a> )";
							}
							?>
							
						</div>
						<div class="panel-body">
							<p><?php echo _("Server Location"); ?>: <strong><?php echo utf8_encode($serverLocation); ?></strong></p>
							<p><?php echo _("IPv4 Address").": ".$ipv4; ?></p>
							<?php if (!empty($ipv6)) { echo "<p>"._("IPv6 Address").": ".$ipv6."</p>"; } ?>
							<p><?php echo _("Your IP Address"); ?>: <strong><a href="#tests" id="userip"><?php echo $_SERVER['REMOTE_ADDR']; ?></a></strong></p>
						</div>
					</div>
				</div>
				<div class="col-sm-6">
					<div class="panel panel-default">
						<div class="panel-heading"><?php echo _("Network Test Files"); ?></div>
						<div class="panel-body">
							<h4><?php echo _("IPv4 Download Test"); ?></h4>
							<?php
								foreach ($testFiles as $val) 
									{
									echo "<a href=\"";
									if ( !empty($siteUrlv4)) { echo $siteUrlv4; }
									else  { echo $siteUrl; }
									echo "/{$val}.bin\" class=\"btn btn-xs btn-default\">{$val}</a> ";
									}
							?>
							<?php
							if (!empty($ipv6)) 
								{
								echo "<h4>"._("IPv6 Download Test")."</h4>";
								foreach ($testFiles as $val) 
									{
									echo "<a href=\"";
									if ( !empty($siteUrlv6)) { echo $siteUrlv6; }
									else  { echo $siteUrl; }
									echo "/{$val}.bin\" class=\"btn btn-xs btn-default\">{$val}</a> ";
									}
								} 
							?>
						</div>
					</div>
				</div>
			</div>
			
			<!-- Network Tests -->
		  
			<div class="row">
				<div class="col-xs-12">
					<div class="panel panel-default">
						<div class="panel-heading"><?php echo _("Network tests"); ?></div>
						<div class="panel-body">
							<form class="form-inline" id="networktest" action="#results" method="post">
							
								<div id="hosterror" class="form-group">
									<div class="controls">
										<input id="host" name="host" type="text" class="form-control" placeholder="<?php echo _("Host or IP address"); ?>" />
									</div>
								</div>
								<div class="form-group">
									<select name="cmd" class="form-control">
										<?php 
										  if (empty($host)) { echo '<option value="host">host</option>'; }
										  if ( (!empty($ipv6)) and (empty($host)) ) { echo '<option value="host6">host6</option>'; }
										  if (empty($mtr)) { echo '<option value="mtr">mtr</option>'; }
										  if ( (!empty($ipv6)) and (empty($mtr)) ) { echo '<option value="mtr6">mtr6</option>'; }
										  if (empty($ping)) { echo '<option value="ping" selected="selected">ping</option>'; }
										  if ( (!empty($ipv6)) and (empty($ping)) ) { echo '<option value="ping6">ping6</option>'; }
										  if (empty($traceroute)) { echo '<option value="traceroute">traceroute</option>'; }
										  if ( (!empty($ipv6)) and (empty($traceroute)) ) { echo '<option value="traceroute6">traceroute6</option>'; }
										  ?>
									</select>
								</div>
						
								<button type="submit" id="submit" name="submit" class="btn btn-success"><?php echo _("Run Test"); ?></button>
							</form>
						</div>
					</div>
					
				</div>
			</div>

			<!-- Results -->
			<div class="row" id="results" style="display:none">
				<div class="col-xs-12">
					<div class="panel panel-default">
						<div class="panel-heading"><? echo _("Results"); ?></div>
						<div class="panel-body">
						
							<pre id="response" style="display:none"></pre>
						</div>
					</div>
				</div>
			</div>
		  
			<footer class="footer">
				<p class="pull-right">
					<a href="#"><?php echo _("Back to top"); ?></a>
				</p>
				<p>
				<?php echo _("Powered by").": "; ?><a target="_blank" href="http://github.com/telephone/LookingGlass">LookingGlass</a> | 
				<?php echo _("Modified by").": "; ?><a target="_blank" href="https://github.com/StadtBadWurzach/LookingGlass">Stadt Bad Wurzach</a> | 
				<?php echo _("Language").": "; ?> <a href="?lang=en_US">EN</a> <a href="?lang=de_DE">DE</a>
				</p>
			</footer>

		</div>

		
		<script src="assets/js/jquery-1.12.4.min.js"></script>
		<script src="assets/js/LookingGlass.min.js"></script>
		<script src="assets/js/XMLHttpRequest.min.js"></script>
	</body>
</html>