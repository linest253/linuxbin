#!//usr/local/bin/python3.4

#clusters = ['seavvnetapp01', 'tukvvnetapp01', 'igqprnetapp01']
#for cluster in clusters:
#	print (cluster)

import sys
sys.path.append("/usr/local/lib/netapp-manageability-sdk/lib/python/NetApp")
from NaServer import *


def print_usage():
    print ("Usage: hello_ontapi.py <filer> <user> <password> \n")
    print ("<filer> -- Filer name\n")
    print ("<user> -- User name\n")
    print ("<password> -- Password\n")
    sys.exit (1)

args = len(sys.argv) - 1

if(args < 3):
   print_usage()

filer = sys.argv[1]
user = sys.argv[2]
password = sys.argv[3]

s = NaServer(filer, 1, 1)
s.set_server_type("Filer")
s.set_admin_user(user, password)
s.set_transport_type("HTTPS")
s.set_port(443)
# The following only works is set_style"CERTIFICATE) is set
# Have to set up CERTS first
s.set_server_cert_verification("False")
output = s.invoke("system-get-version")

if(output.results_errno() != 0):
   r = output.results_reason()
   print("Failed: \n" + str(r))

else :
   r = output.child_get_string("version")
   print (r + "\n")


