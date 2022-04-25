var http = require('http');

//Create a server 
http.createServer(function (req, res) {
  res.write('Hello World! My name is Prasanna jadhav'); //write a response to the browser
  res.end(); //end the response
}).listen(8050); //the server object listens on port 8080 

console.log('Server started ..');