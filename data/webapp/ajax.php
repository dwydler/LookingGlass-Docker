<?php
/**
 * LookingGlass - User friendly PHP Looking Glass
 *
 * @package     LookingGlass
 * @author      Nick Adams <nick@iamtelephone.com>
 * @copyright   2015 Nick Adams.
 * @link        http://iamtelephone.com
 * @license     http://opensource.org/licenses/MIT MIT License
 * @version     1.4.0
 */

// Set an unique session name
session_name("consentUUID");

// Start new or resume existing session
session_start();


// csrf protection
if (!empty($_GET["csrf"])) {
	
	// compare both values
    if (hash_equals($_SESSION["csrf"], $_GET["csrf"])) {

		// check whether command and host are set
		if (isset($_GET['cmd']) && isset($_GET['host'])) {
			// define available commands
			$cmds = array('host', 'host6', 'mtr', 'mtr6', 'ping', 'ping6', 'traceroute', 'traceroute6');
			// verify command
			if (in_array($_GET['cmd'], $cmds)) {
				// include required scripts
				$required = array('LookingGlass.php', 'RateLimit.php', 'Config.php');
				foreach ($required as $val) {
					require 'LookingGlass/' . $val;
				}

				// check if variable value is an int
				if( !preg_match("/^\d+$/",$rateLimit) ) {
					$rateLimit = 0;
				}

				// instantiate LookingGlass & RateLimit
				$lg = new Telephone\LookingGlass();
				$limit = new Telephone\LookingGlass\RateLimit($rateLimit);

				// check IP against database
				$limit->rateLimit($rateLimit);

				// execute command
				$output = $lg->{$_GET['cmd']}($_GET['host']);
				if ($output) {
					exit();
				}
			}
		}
	}
}

// The handover from Javascript to PHP $_SESSION
if (!empty($_GET["theme"])) {
	$_SESSION["theme"] = $_GET["theme"];
	echo $_SESSION["theme"];
	exit();
}

// report error
exit('Unauthorized request!');

