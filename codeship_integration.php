<?php

// Load a secrets file.
// See the included example.secrets.json and instructions in README.
$secrets = _get_secrets('codeship_integration_secrets.json');

// Create url for curl.
$url = $secrets['codeship_url'] . $secrets['build_id'] .'/restart.json?api_key=' . $secrets['api_key'];

//Create curl post request to hit the Jenkins webhook
$curl = curl_init($url);

//Declare request as a post.
curl_setopt($curl, CURLOPT_POST, true);

//Execute the request
$response = curl_exec($curl);

if ($response) {
  echo "Build Queued";
}
else {
  echo "Build Failed";
}


/**
 * Get secrets from secrets file.
 *
 * @param string $file path within files/private that has your json
 */
function _get_secrets($file)
{
  $secrets_file = $_SERVER['HOME'] . '/files/private/' . $file;
  if (!file_exists($secrets_file)) {
    die('No secrets file found. Aborting!');
  }
  $secrets_json = file_get_contents($secrets_file);

  $secrets = json_decode($secrets_json, 1);
  if ($secrets == FALSE) {
    die('Could not parse json in secrets file. Aborting!');
  }
  return $secrets;
}