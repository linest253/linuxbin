#!/usr/bin/env python3
 
import sys
sys.path.append("/usr/local/lib/netapp-manageability-sdk/lib/python/NetApp")
# Could create and environmenr $VAR called NMSDKpy with that path then:
# sys.path.append("NMSDKpy")
# Cpuld do the same for .pem and .key file below too.
from NaServer import *
 
cluster = "seatsnetapp01"
transport = "HTTPS"
port = 443
style = "CERTIFICATE"
cert = "NetappAPI.pem"
key = "NetappAPI.key"
 
s = NaServer(cluster, 1, 30)
s.set_transport_type(transport)
s.set_port(port)
s.set_style(style)
s.set_server_cert_verification(0)
s.set_client_cert_and_key(cert, key)
 
api = NaElement("vserver-get-iter")
output = s.invoke_elem(api)
if (output.results_status() == "failed"):
    r = output.results_reason()
    print("Failed: " + str(r))
    sys.exit(2)
 
#ontap_version = output.child_get_string("version")
#print (output.sprintf())
print (output.vserver-name)
