<html>
  <head>
    <title>Removing Wifi Configuration</title>
  </head>

  <body>
    <h1>Remove Wifi Configuration</h1>
    <p>This removes the wifi based on the previously submited form: </p>
    <h2>Result of set:</h2>
    <?php exec('/opt/calmeq-mypi/bin/removewifi.sh '. $_POST['id'],
                $outtext); echo implode("<br>", $outtext) ?>
    <br>
    <br>
    <a href="wifi.php">Back</a>
  </body>


</html>
