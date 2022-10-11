<?php
ini_set('display_errors', 1);
error_reporting(E_ALL ^ E_NOTICE ^ E_DEPRECATED ^ E_STRICT);

require_once "Mail.php";

$host = "ssl://smtp.gmail.com";
$username = "example@gmail.com";
$password = "P455w0rd";
$port = "465";

$from = "example@gmail.com";
$to = "example@gmail.com";

$subject = "PHP Mail Test script";
$body = "This is a test to check the PHP Mail functionality";

$headers = array(
    'From' => $from, 'To' => $to, 'Subject' => $subject, 'Reply-To' => $from,
);

$args = array(
    'host' => $host, 'port' => $port, 'auth' => true,
    'username' => $username, 'password' => $password);

$smtp = Mail::factory('smtp', $args);
$mail = $smtp->send($to, $headers, $body);

if (PEAR::isError($mail)) {
    echo ("<p>" . $mail->getMessage() . "</p>");
} else {
    echo ("<p>Message successfully sent!</p>");
}
