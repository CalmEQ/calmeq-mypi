<!-- 
This file displays and configures the wifi for a raspberry pi
It relies on php for simple scripting, and html
It is designed to be shown if the raspberry is unable to connect to one of 
its saved networks, and had to create its own wifi network
Then a simple phone app can pull up this page and configure the wifi

for development we're going to fake some of the 
-->

<html>

<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->

  <title>Wifi Configuration</title>

  <!-- Latest compiled and minified CSS -->
  <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/css/bootstrap.min.css">

  <!-- Optional theme -->
  <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/css/bootstrap-theme.min.css">

  <!-- Custom styles for this template -->
  <link href="theme.css" rel="stylesheet">

</head>

<body>
  <div class="container theme-base" role="main">

    <h1>Wifi Configuration</h1>
    <p>This page allows you to see and set the wifi configuration for the raspberry pi</p>
    <h3>Current Status</h3>
    <p>If an ip address is shown on a line with "inet addr" then the WiFi is up and connected</p>
    <pre><?php exec('/sbin/ifconfig wlan0', $ipinfo); echo implode("<br>", $ipinfo) ?></pre>
    <h3>Saved Networks</h3>
    <?php exec( '/opt/calmeq-mypi/bin/listnetworks.sh', $list); echo implode( "", $list) ?>

    <div class="row">
      <div class="col-sm-4">
        <div class="panel panel-primary">
          <div class="panel-heading">
            <h3 class="panel-title">Add new network</h3>
          </div>
          <div class="panel-body">
            <form action="setwifi.php" method="post">
              <p>SSID:
                <br>
                <input type="text" name="ssid" />
              </p>
              <p>Passcode:
                <br>
                <input type="text" name="passcode" />
              </p>
              <p>KeyMgmt:
                <br>
                <select name="keymgmt">
                  <option value="WPA-PSK">WPA-PSK</option>
                </select>
              </p>
              <p>
                <input type="submit" class="btn btn-primary" value="Add" />
              </p>
            </form>
          </div>
        </div>
      </div>
      <div class="col-sm-4">
        <div class="panel panel-default">
          <div class="panel-heading">
            <h3 class="panel-title">Remove network</h3>
          </div>
          <div class="panel-body">
            <form action="removewifi.php" method="post">
              <p>ID:
                <br>
                <input type="text" name="id" />
              </p>
              <p>
                <input type="submit" />
              </p>
            </form>
          </div>
        </div>
      </div>
      <div class="col-sm-4">
        <div class="panel panel-default">
          <div class="panel-heading">
            <h3 class="panel-title">Reset network</h3>
          </div>
          <div class="panel-body">
            <form action="resetwifi.php" method="post">
              <p>ID:
                <br>
                <input type="text" name="id" />
              </p>
              <p>
                <input type="submit" />
              </p>
            </form>
          </div>
        </div>
      </div>
    </div>
  </div>

  <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.2/jquery.min.js"></script>
  <!-- Include all compiled plugins (below), or include individual files as needed -->

  <!-- Latest compiled and minified JavaScript -->
  <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/js/bootstrap.min.js"></script>

</body>



</html>
