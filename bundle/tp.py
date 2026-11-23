# tp.py recv PORT  -> prints MB received / s ;  tp.py send HOST PORT SECONDS
import socket,sys,time
if sys.argv[1]=='recv':
    s=socket.socket();s.setsockopt(socket.SOL_SOCKET,socket.SO_REUSEADDR,1);s.bind(('',int(sys.argv[2])));s.listen(1)
    c,_=s.accept();n=0;t=time.time()
    while True:
        b=c.recv(65536)
        if not b:break
        n+=len(b)
    dt=time.time()-t;print('%.0f kbit/s (%d bytes in %.1fs)'%(n*8/dt/1000,n,dt))
elif sys.argv[1]=='send':
    c=socket.create_connection((sys.argv[2],int(sys.argv[3])));buf=b'x'*16384;end=time.time()+float(sys.argv[4])
    while time.time()<end:c.sendall(buf)
    c.close()
if sys.argv[1]=='get':
    import urllib.request;t=time.time();n=len(urllib.request.urlopen(sys.argv[2]).read());dt=time.time()-t
    print('download %.0f kbit/s (%d bytes in %.1fs)'%(n*8/dt/1000,n,dt))
