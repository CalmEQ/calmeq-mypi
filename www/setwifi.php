<html>
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->

    <title>Adding Wifi Configuration</title>

    <!-- Latest compiled and minified CSS -->
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/css/bootstrap.min.css">

    <!-- Optional theme -->
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/css/bootstrap-theme.min.css">

    <!-- Custom styles for this template -->
    <link href="theme.css" rel="stylesheet">

  </head>

  <body>
    <div class="container theme-base" role="main">

    <h1>Adding Wifi Configuration</h1>
    <p>This adds the wifi based on the previously submited form: </p>
    <h3>Result of add</h3>
    <pre><?php exec('/opt/calmeq-mypi/bin/setwifi.sh '. $_POST['ssid'] 
               .' '. $_POST['passcode'] .' '. $_POST['keymgmt'], $outtext); echo implode("<br>", $outtext) ?></pre>
    <br>
    <br>
    <a href="wifi.php"><button class="btn btn-primary">Back</button></a>


    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.2/jquery.min.js"></script>
    <!-- Include all compiled plugins (below), or include individual files as needed -->

    <!-- Latest compiled and minified JavaScript -->
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/js/bootstrap.min.js"></script>

    </div>
  </body>


</html>
