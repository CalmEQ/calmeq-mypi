<html>
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->

    <title>CalmEQ RaspberryPi</title>
    <!-- Latest compiled and minified CSS -->
    <link rel="stylesheet" href="bootstrap/css/bootstrap.min.css">

    <!-- Optional theme -->
    <link rel="stylesheet" href="bootstrap/css/bootstrap-theme.min.css">

    <!-- Custom styles for this template -->
    <link href="theme.css" rel="stylesheet">

  </head>

  <body>
    <div class="container theme-base" role="main">

      <h1>CalmEQ Raspberry System</h1>
      <p>Welcome to the CalmEQ Raspberry Configuration System</p>
      
      <h2>System Status</h2>
      <p><pre><?php system('uname -a') ?></pre></p>

      <h2>GPS Info</h2>
      <br>
      <a href="wifi.php"><button class="btn btn-lg btn-primary">Wifi Configuration</button></a><br>

      <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.2/jquery.min.js"></script>
      <!-- Include all compiled plugins (below), or include individual files as needed -->

      <!-- Latest compiled and minified JavaScript -->
      <script src="bootstrap/js/bootstrap.min.js"></script>

    </div>
  </body>

</html>

