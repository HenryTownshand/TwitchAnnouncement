<?php 		
$account = "<YOUR ACCOUNT>";
$token = "<YOUR TOKEN>";
$clientid = "<YOUR CLIENTID>";

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
	$result = '{"id":" ","user_id":" ","user_login":" ","user_name":" ","game_id":" ","game_name":" ","type":" ","title":" ","viewer_count":" ","started_at":" ","language":" ","thumbnail_url":" ","tag_ids":" ","is_mature":" "}';
	print_r ($result);
}else{
	print_r ($result);
}
?>