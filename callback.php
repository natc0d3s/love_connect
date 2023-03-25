<?php

// This is your callback page you set in your lovense developer settings and this is all you need on external server side

if($json = json_decode(file_get_contents("php://input"), true)) {
    //print_r($json);
    $data = $json;
    
    // extracting SLURL which was set as utoken from lovense callback to forward it to SL server aka. your LSL lovense app
    $url = urldecode($json["utoken"]);
    
    //echo "<br><br>" . $url;
    
    $curl = curl_init($url);
    curl_setopt($curl, CURLOPT_URL, $url);
    curl_setopt($curl, CURLOPT_POST, true);
    curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);

    $headers = array(
      "Content-Type: application/json",
    );
    curl_setopt($curl, CURLOPT_HTTPHEADER, $headers);
    $body = json_encode($data);
    curl_setopt($curl, CURLOPT_POSTFIELDS, $body);

    //for debug only
    curl_setopt($curl, CURLOPT_SSL_VERIFYHOST, false);
    curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, false);

    $resp = curl_exec($curl);
    curl_close($curl);
    var_dump($resp);
    
    // for logging / debugging --> for security hide this from access through webserver
    $logfile = fopen("love.log", "a") or die("love.log error - unable to open file!"); // option w for overwrite
    $log = json_encode($data);
    fwrite($logfile, date("Y-m-d  H:i:s: ") . $log . "\n");
    fclose($logfile);
     

} else {
    //print_r($_POST);
    $data = $_POST;

}

?>
