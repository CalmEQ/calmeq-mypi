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
    <title>Wifi Configuration</title>
  </head>
  
  <body>
    <h1>Wifi Configuration</h1>
    <p>This page allows you to see and set the wifi configuration for the raspberry pi</p>
    <h2>Current Status: </h2>
    <pre><?php exec('/sbin/ifconfig wlan0', $ipinfo); echo implode("<br>", $ipinfo) ?></pre>
    <h2>Saved Networks</h2>
    <table>
      <tr>
        <td>SSID</td><td>Passcode</td><td>KeyMgmt</td>
      </tr>
    </table>
    <pre><?php system('whoami'); ?></pre>
    <pre><?php exec('/home/pi/calmeq-mypi/bin/listnetworks.sh', $list); echo implode("<br>", $list) ?></pre>

  <h2>Set new network</h2>
  <form action="setwifi.php" method="post">
    <p>SSID: <input type="text" name="ssid" /></p>
    <p>Passcode: <input type="text" name="passcode" /></p>
    <p>KeyMgmt: <select name="keymgmt"><option value="WPA-PSK">WPA-PSK</option></select></p>
    <p><input type="submit"/></p>
  </form>

  </body>
  
  
  
</html>
