import os
import threadpool
import protocol
import asyncdispatch
import asyncnet

proc connect(socket: AsyncSocket, serverAddr: string) {.async.} =
  echo("Connecting to ", serverAddr)
  await socket.connect(serverAddr, 7687.Port)
  echo("Connected.")

  while true:
    let line = await socket.recvLine()
    let parsed = parseMessage(line)
    echo(parsed.username, ": ", parsed.message)


if paramCount() != 2:
  quit("Please specify the server address and your name, e.g. 'localhost Ante'")

let serverAddr = paramStr(1)
let name = paramStr(2)
var socket = newAsyncSocket()

echo("Connecting to ", serverAddr)
asyncCheck connect(socket, serverAddr)

echo("Chat application started.")

var messageFlowVar = spawn stdin.readLine()
while true: 
  if messageFlowVar.isReady():
    let message = createMessage(name, ^messageFlowVar)
    asyncCheck socket.send(message)
    messageFlowVar = spawn stdin.readLine()

  asyncdispatch.poll()



