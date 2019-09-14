#!/usr/bin/env python3

'''
https://wiki.python.org/moin/TcpCommunication
'''

import sys
import socket
import struct

if sys.version_info[0] < 3:
    raise Exception("Python 3 or a more recent version is required.")

TCP_IP = '127.0.0.1'
TCP_PORT = 2000

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.bind((TCP_IP, TCP_PORT))
s.listen(1)

conn, addr = s.accept()

UINT32T_SIZE = 4

while True:
    data = conn.recv(UINT32T_SIZE)
    msg_size = struct.unpack('I', data)[0]

    msg = conn.recv(msg_size).decode('ascii')
    print(msg)

conn.close()