#!/usr/bin/php
<?php
if ($argc < 2) {
?>
  Usage:
  <?php echo $argv[0]; ?> <token> [<token> <token>...]

  <token> are the device tokens to send the push notification to.

<?php
} 

if ($argc < 2) {
    exit(1);
}

echo 'There are ' . ($argc - 1) . ' tokens.' . PHP_EOL;

// Put your private key's passphrase here:
$passphrase = 'foo';

// Put your alert message here:
$message = 'Yo';

////////////////////////////////////////////////////////////////////////////////

function send_notification($deviceToken, $apns_stream) {
    // Create the payload body
    $body['aps'] = array(
    // 	'alert' => $message,
        'sound' => 'default'
        );

    // Encode the payload as JSON
    $payload = json_encode($body);

    // Build the binary notification
    $msg = chr(0) . pack('n', 32) . pack('H*', $deviceToken) . pack('n', strlen($payload)) . $payload;

    // Send it to the server
    $result = fwrite($apns_stream, $msg, strlen($msg));

    if (!$result)
        echo 'Message not delivered' . PHP_EOL;
    else
        echo 'Message successfully delivered' . PHP_EOL;
}

$ctx = stream_context_create();
stream_context_set_option($ctx, 'ssl', 'local_cert', 'apple_push_notification.pem');
// stream_context_set_option($ctx, 'ssl', 'passphrase', $passphrase);

// Open a connection to the APNS server
$fp = stream_socket_client(
	'ssl://gateway.push.apple.com:2195', $err,
	$errstr, 60, STREAM_CLIENT_CONNECT|STREAM_CLIENT_PERSISTENT, $ctx);

if (!$fp)
	exit("Failed to connect: $err $errstr" . PHP_EOL);

echo 'Connected to APNS' . PHP_EOL;

for ($i = 1; $i < $argc; $i++) {
    send_notification($argv[$i], $fp);
}

// Close the connection to the server
fclose($fp);
