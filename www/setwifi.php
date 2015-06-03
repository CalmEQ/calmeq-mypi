<html>
  <head>
    <title>Setting Wifi Configuration</title>
  </head>

  <body>
    <h1>Setting Wifi Configuration</h1>
    <p>This sets the wifi based on the previously submited form: </p>
    <h2>Result of set:</h2>
    <?php exec('/opt/calmeq-mypi/bin/setwifi.sh '. $_POST['ssid'] 
               .' '. $_POST['passcode'] .' '. $_POST['keymgmt'], $outtext); echo implode("<br>", $outtext) ?>
    <br>
    <br>
    <a href="wifi.php">Back</a>
  </body>


</html>
