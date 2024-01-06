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
namespace Telephone\LookingGlass;

/**
 * Implement rate limiting of network commands
 */
class RateLimit
{
    /**
     * Check rate limit against SQLite database
     *
     * @param  integer $limit
     *   Number of commands per hour
     * @return boolean
     *   True on success
     */
    public function rateLimit($limit)
    {
        // check if rate limit is disabled
        if ($limit === 0) {
            return false;
        }

        /**
         * check for DB file
         * if nonexistent, no rate limit is applied
         */
        if (!file_exists('LookingGlass/ratelimit.db')) {
            return false;
        }

        // connect to DB
        try {
            $dbh = new \PDO('sqlite:LookingGlass/ratelimit.db');
        } catch (PDOException $e) {
            exit($e->getMessage());
        }

        // check for IP
        $q = $dbh->prepare('SELECT * FROM RateLimit WHERE ip = ?');
        $q->execute(array($_SERVER['REMOTE_ADDR']));
        $row = $q->fetch(\PDO::FETCH_ASSOC);

        // save time by declaring time()
        $time = time();

        // if IP does not exist
        if (!isset($row['ip'])) {
            // create new record
            $q = $dbh->prepare('INSERT INTO RateLimit (ip, hits, accessed) VALUES (?, ?, ?)');
            $q->execute(array($_SERVER['REMOTE_ADDR'], 1, $time));

			// check error code of exec
			$this->ErrorCheck($q);
        }

        // typecast SQLite results
        $accessed = (int) $row['accessed'] + 3600;
        $hits = (int) $row['hits'];

        // apply rate limit
        if ($accessed > $time) {
            if ($hits >= $limit) {
                $reset = (int) (($accessed - $time) / 60);
                if ($reset <= 1) {
                    exit('Rate limit exceeded. Try again in 1 minute.');
                }
                exit('Rate limit exceeded. Try again in '.$reset.' minutes.');
            }
            // update hits
            $q = $dbh->prepare('UPDATE RateLimit SET hits = ? WHERE ip = ?');
            $q->execute(array(($hits + 1), $_SERVER['REMOTE_ADDR']));
			
			// check error code of exec
			$this->ErrorCheck($q);
        } else {
            // reset hits + accessed time
            $q = $dbh->prepare('UPDATE RateLimit SET hits = ?, accessed = ? WHERE ip = ?');
            $q->execute(array(1, time(), $_SERVER['REMOTE_ADDR']));
			
			// check error code of exec
			$this->ErrorCheck($q);
        }
		
		// close database connection
        $dbh = null;
		
        return true;
    }
	
	/**
     * Check errror code of sql execution
     *
     * @param  array $error
     *   Array of errorCode und ErrorInfo
     * @return boolean
     *   True on success
     */
	private function ErrorCheck ($error) {

		$errors = $error->errorInfo();
		
		switch ($errors[1]) {
			case '1':
				exit('Error: SQL error or missing database.');
			case '2':
				exit('Error: An internal logic error in SQLite.');
			case '3':
				exit('Error: Access permission denied.');
			case '4':
				exit('Error: Callback routine requested an abort.');
			case '5':
				exit('Error: The database file is locked.');
			case '6':
				exit('Error: A table in the database is locked.');
			case '7':
				exit('Error: A malloc() failed.');
			case '8':
				exit('Error: Attempt to write a readonly database.');
			case '9':
				exit('Error: Operation terminated by sqlite_interrupt().');
			case '10':
				exit('Error: Some kind of disk I/O error occurred.');
			case '11':
				exit('Error: The database disk image is malformed.');
			case '12':
				exit('Error: (Internal Only) Table or record not found.');
			case '13':
				exit('Error: Insertion failed because database is full.');
			case '14':
				exit('Error: Unable to open the database file.');
			case '15':
				exit('Error: Database lock protocol error.');
			case '16':
				exit('Error: (Internal Only) Database table is empty.');
			case '17':
				exit('Error: The database schema changed.');
			case '18':
				exit('Error: Too much data for one row of a table.');
			case '19':
				exit('Error: Abort due to contraint violation.');
			case '20':
				exit('Error: Data type mismatch.');
			case '21':
				exit('Error: Library used incorrectly.');
			case '22':
				exit('Error: Uses OS features not supported on host.');
			case '23':
				exit('Error: Authorization denied.');
			case '100':
				exit('Error: sqlite_step() has another row ready.');
			case '103':
				exit('Error: sqlite_step() has finished executing.');
			default:
				return true;
		}
	}
}
