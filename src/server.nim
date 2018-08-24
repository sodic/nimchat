import asyncdispatch
import asyncnet
import sequtils
import future

type
  Client = ref object
    socket:AsyncSocket
    netAddr: string
    id: int
    connected:  bool

  Server = ref object
    socket: AsyncSocket
    clients: seq[Client]

proc newServer() : Server = Server(socket: newAsyncSocket(), clients: @[])

proc `$`(client: Client) : string = 
  $client.id & "(" & client.netAddr & ")"

proc processMessage(server: Server, client: Client) {.async.} =
  while true:
    let line = await client.socket.recvLine()
    
    if line.len == 0:
      echo(client, " disconnected")
      client.connected = false
      client.socket.close()
      return
    
    echo(client, "sent: ", line)

    for c in server.clients.filter(c => c.id != client.id):
        await c.socket.send(line & "\c\l")

proc serverLoop(server: Server, port = 7687) {.async.} = 
  server.socket.bindAddr(port.Port)
  server.socket.listen()

  while true:
    let (netAddr, clientSocket)= await server.socket.acceptAddr()
    echo("Accepted connection from ", netAddr)
  
    let client = Client(
      socket: clientSocket,
      netAddr: netAddr,
      id: server.clients.len,
      connected: true
    )

    server.clients.add(client)
    asyncCheck processMessage(server, client);


var server = newServer()
waitFor serverLoop(server)