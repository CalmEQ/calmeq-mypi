<html>
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->

    <title>Removing Wifi Configuration</title>
    <!-- Latest compiled and minified CSS -->
    <link rel="stylesheet" href="bootstrap/css/bootstrap.min.css">

    <!-- Optional theme -->
    <link rel="stylesheet" href="bootstrap/css/bootstrap-theme.min.css">

  </head>

  <body>
    <div class="container theme-base" role="main">

    <h1>Remove Wifi Configuration</h1>
    <p>This removes the wifi based on the previously submited form: </p>
    <h3>Result of remove</h3>
    <pre><?php exec('/opt/calmeq-mypi/bin/removewifi.sh '. $_POST['id'],
                $outtext); echo implode("<br>", $outtext) ?></pre>
    <br>
    <br>
    <a href="wifi.php"><button class="btn btn-primary">Back</button></a>

    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.2/jquery.min.js"></script>
    <!-- Include all compiled plugins (below), or include individual files as needed -->

    <!-- Latest compiled and minified JavaScript -->
    <script src="bootstrap/js/bootstrap.min.js"></script>

    </div>
  </body>

</html>
