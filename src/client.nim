import os, threadpool

if paramCount() == 0:
  quit("Please specify the server address, e.g. localhost")

let serverAddress = paramStr(1)

echo("Connecting to ", serverAddress)

echo("Chat application started")

while true: 
  let message = spawn stdin.readline()
  echo("Sending message \"", ^message, "\"")


