<?php
session_start();

// The handover from Javascript to PHP $_SESSION
if (!empty($_GET["theme"])) {
    $_SESSION["theme"] = $_GET["theme"];
    echo $_SESSION["theme"];
}

// report error
exit('Unauthorized request!');

?>