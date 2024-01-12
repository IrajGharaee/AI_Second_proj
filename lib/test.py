import socket

host = "localhost"
port = 3000

# Create a socket object
server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

# Bind the socket to a specific address and port
server_socket.bind((host, port))

# Listen for incoming connections
server_socket.listen()

print(f"Server listening on {host}:{port}")

while True:
    # Accept a connection from a client
    client_socket, client_address = server_socket.accept()
    print(f"Connection from {client_address}")

    # Send data to the client
    data_to_send = "Hello from Python!"
    client_socket.sendall(data_to_send.encode("utf-8"))

    # Close the connection
    client_socket.close()
