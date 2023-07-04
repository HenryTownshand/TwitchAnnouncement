<?php 		
$account = $_GET['id']; // Не трогать
$token = ""; // Генерируем токен https://twitchtokengenerator.com
$clientid = ""; // Берём CLIENT ID https://twitchtokengenerator.com

function infoTwitchUser($name, $token, $clientid)
{	
	$ch = curl_init(); 
	curl_setopt($ch, CURLOPT_URL,"https://api.twitch.tv/helix/streams?user_login=$name"); 
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1); 
	curl_setopt($ch, CURLOPT_TIMEOUT, 60); 
	curl_setopt($ch, CURLOPT_HTTPHEADER, array( 
		"Content-type: application/json",
		"Authorization: Bearer $token",
		"Client-ID: $clientid",
	)); 
	$data = curl_exec($ch);  
	if (curl_errno($ch)) { 
		echo "Error: " . curl_error($ch); 
		curl_close($ch); 
	} else {
		$data = json_decode($data, true);
		$output = $data['data'][0];
		curl_close($ch); 
	} 
	return json_encode($output);

}

$result = infoTwitchUser($account, $token, $clientid);

if($result == "null")
{
	$result = '{"user_login":" "}';
	print_r ($result);
}else{
	print_r ($result);
}
?>