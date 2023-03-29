// ♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥
// LOVE CONNECT - a minimalistic example how to build a SL Lovense app 
// ♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥

// for callback data you need an external webserver with php 

string dev_token = "here_goes_your_lovense_developer_token_keep_it_a_secret"; // your lovense dev token; without valid token this app won't work!

string api_url = "https://api.lovense-api.com/api/lan/v2/command";

string qr_url = "https://api.lovense-api.com/api/lan/getQrCode";

integer debug = 1; //set t 0 for no debug messages

string url; // sl slurl which will be used as utoken so callback handler can forward callback response from lovense api to SL
key user_uuid;
integer chan = -998876;
integer connected;

key urlRequestId;
key qrRequestId;
key comRequestId;

list gHttpParams = [
    HTTP_METHOD, "POST",
    HTTP_MIMETYPE, "application/json",
    HTTP_VERIFY_CERT, FALSE
    ];

// functions

request_qr(){

    // here we request the QR for pairing

    string json = llList2Json(JSON_OBJECT, [
        "token", dev_token, // Lovense developer token
        "uid", (string)user_uuid,  // user ID on your website
        "uname", llGetUsername(user_uuid),  // user nickname on your website
        "utoken", llEscapeURL(url),  // URL of your SL app; be aware, that you get a new URL on sim restart and on teleport !!! 
        "v", "2"
    ]);
    
    qrRequestId = llHTTPRequest(qr_url, gHttpParams, json);


}

vibe(){

    // just a simple vibration; check lovense developer reference for more: https://developer.lovense.com/standard-solutions.html#standard-solutions-1
    
    string json = llList2Json(JSON_OBJECT, [
        "token", dev_token, // Lovense developer token
        "uid", (string)user_uuid,  // user ID on your website
        "command", "Function",
        "action", "Vibrate:5",
        "timeSec", 1,
        "loopRunningSec", 0,
        "loopPauseSec", 0,
        "apiVer", 1
    ]);
    
    comRequestId = llHTTPRequest(api_url, gHttpParams, json);
  
}

// main

default
{
       state_entry()
    {
        user_uuid = llGetOwner();
        urlRequestId = llRequestURL();
 
    }

    touch_start(integer num_detected)
    {
    
       vibe();  
    
    }

    http_response(key request_id, integer status, list metadata, string body)
    {
        
        if (request_id == qrRequestId)
        {
            if(debug)llOwnerSay(body);

            string qr_url = llJsonGetValue( body, [ "data", "qr" ] );

            if(debug)llOwnerSay(qr_url);

            llDialog(user_uuid, "\n \nClick to pair your toys with QR Code:\n \n" +  qr_url, ["OK"], chan);

        }
        
        if(request_id == comRequestId){

            // here we get the response if vibration command was susscessfully received >> {"result":true,"code":200,"message":"Success"}
            if(debug) llOwnerSay(body);

        }

    }

    http_request(key id, string method, string body)
    {
     
        if (id == urlRequestId)
        {
            if (method == URL_REQUEST_DENIED) llOwnerSay("error while retrieving a free URL:\n \n" + body);

            else if (method == URL_REQUEST_GRANTED)
            {
            url = body;
            
            if(debug) llOwnerSay(url);
            
            request_qr(); // here we request the QR code after successfully retreiving a URL for our SL app

            }
        }


        if(method == "POST"){ // receiving lovense callback data (JSON format) forwarded by your external server via callback.php

            llHTTPResponse(id,200,body);
            
            if(debug) llOwnerSay(body);

            //here you can parse the shit out of the forwarded callback data from lovense and uitilize it for your SL app
            // every 10 seconds (base value, you can set value in your developer settings) you receive a heartbeat from lovense, so you can for example utilize later added toys
            // but be aware on sim restart and teleport your SL app URL is not valid anymore, but you can still send commands to user toys, so keep that in mind when you create apps

            string v = llJsonGetValue( body, [ "uid"] );
            
            // if(debug) llOwnerSay(v);

            if(v == (string)user_uuid && connected == 0){ // just a simple check if registered uid is your UUID and you received the right JSON POST DATA
                
                llDialog(user_uuid, "\n \nYou succesfelluly connected your toy(s) with this app:\n \nHappy vibing!", ["OK"], chan);
                connected = 1;
            
            }
        }
    }


    on_rez( integer start_param)
    {
        llResetScript();
    }

}
