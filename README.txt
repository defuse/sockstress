      _____  ____   _____ _  __ _____ _______ _____  ______  _____  _____ 
     / ____|/ __ \ / ____| |/ // ____|__   __|  __ \|  ____|/ ____|/ ____|
    | (___ | |  | | |    | ' /| (___    | |  | |__) | |__  | (___ | (___  
     \___ \| |  | | |    |  <  \___ \   | |  |  _  /|  __|  \___ \ \___ \
     ____) | |__| | |____| . \ ____) |  | |  | | \ \| |____ ____) |____) |
    |_____/ \____/ \_____|_|\_\_____/   |_|  |_|  \_\______|_____/|_____/ 
                          
                               CVE-2008-4609
                     https://defuse.ca/sockstress.htm
   
                           By: havoc@defuse.ca
                           Date: April 9, 2012

            This code is explicitly placed into the public domain.

  THIS CODE IS PROVIDED FOR EDUCATIONAL AND ETHICAL SECURITY TESTING PURPOSES 
  ONLY. THE AUTHOR IS NOT RESPONSIBLE FOR ILLEGAL USE OF, OR DAMAGE CAUSED 
  BY, THIS CODE. There is NO WARRANTY, to the extent permitted by law.

=== WHAT IS SOCKSTRESS? =====================================================

    Sockstress is a Denial of Service attack on TCP services discovered in
    2008 by Jack C. Louis from Outpost24 [1]. It works by using RAW sockets
    to establish many TCP connections to a listening service. Because the 
    connections are established using RAW sockets, connections are established
    without having to save any per-connection state on the attacker's machine.
    
    Like SYN flooding, sockstress is an asymmetric resource consumption attack:
    It requires very little resources (time, memory, and bandwidth) to run a 
    sockstress attack, but uses a lot of resources on the victim's machine.
    Because of this asymmetry, a weak attacker (e.g. one bot behind a cable 
    modem) can bring down a rather large web server.

    Unlike SYN flooding, sockstress actually completes the connections, and 
    cannot be thwarted using SYN cookies. In the last packet of the three-way 
    handshake a ZERO window size is advertised -- meaning that the client is 
    unable to accept data -- forcing the victim to keep the connection alive
    and periodically probe the client to see if it can accept data yet.

    This implementation of sockstress takes the idea a little further by 
    allowing the user to specify a payload, which will be sent along with the
    last packet of the three-way handshake, so in addition to opening a 
    connection, the attacker can request a webpage, perform a DNS lookup, etc.

    For more information on sockstress, see its Wikipedia page:
        https://secure.wikimedia.org/wikipedia/en/wiki/Sockstress

    [1] http://www.outpost24.com/

=== HOW DO I COMPILE SOCKSTRESS? ============================================

    The sockstress code has been tested on Debian Linux, using the GCC compiler.

    gcc -Wall -c sockstress.c
    gcc -pthread -o sockstress sockstress.o
    Or, if you have GNU Make, simply run 'make'.

=== HOW DO I USE SOCKSTRESS? ================================================

    *** WARNING: *** 
    The sockstress attack has been known to render operating systems 
    unbootable. NEVER run it on a production system unless all data has been 
    backed up and you are prepared to re-install the OS. Also be aware of 
    stateful routers between the attacker and victim, they might get overloaded
    too. You have been warned.

    Sockstress uses RAW sockets, so you must run the tool as root. You must
    also stop your OS from sending RST packets to the victim in response to
    unrecognized SYN/ACKs sent during the attack. To do so, set an iptables
    rule:
        # iptables -A OUTPUT -p TCP --tcp-flags rst rst -d xx.xx.xx.xx -j DROP
    Where xx.xx.xx.xx is the victim's IP address.

    To view the sockstress help menu, run:
        # ./sockstress -h

    To execute an attack, sockstress requires three parameters:
        1. Victim IP
        2. Victim port
        3. Network interface to send packets from (e.g. eth0)

    For example, to run an attack on port 80 on 127.0.0.1, run:
        # ./sockstress 127.0.0.1:80 eth0
    
    Sockstress also allows the user to control the delay between sent SYN 
    packets. This value is specified in microseconds with the -d option.
    For example, to send a SYN packet every second, run:
        # ./sockstress 127.0.0.1:80 eth0 -d 1000000

    You can also have sockstress send some data to the victim after the 
    connection has been established. Do this by specifying a file containing
    the data with the -p option. For example, to make HTTP requests:
        # ./sockstress 127.0.0.1:80 eth0 -p payloads/http
    ... where payloads/http contains:

    --- BEGIN: payloads/http ---
    GET / HTTP/1.0


    --- END: payloads/http ---
    
    Example payloads for making DNS requests, requesting web pages, and sending
    mail with SMTP are provided in the payloads folder.

    To run a sockstress attack against multiple ports, you must run multiple
    instances of the tool. The attack can be amplified by assigning many IP
    addresses to a single machine and running an instance of the attack from
    each IP. This improves the attack because sockstress will quickly establish
    a connection from every source port, so more IP addresses will be needed to
    open more connections (more sets of source ports).

=== HOW CAN I PREVENT SOCKSTRESS ATTACKS? ===================================

    The only way to completely prevent sockstress attacks is to whitelist
    access to TCP services. This is not practical in most situations, so the
    best that can be done is to rate limit connections with iptables.

    To block an IP after it opens more than 10 connections to port 80 within 
    30 seconds, install the following iptables rules:

    # iptables -I INPUT -p tcp --dport 80 -m state --state NEW -m recent --set
    # iptables -I INPUT -p tcp --dport 80 -m state --state NEW -m recent  \
        --update --seconds 30 --hitcount 10 -j DROP

 Src: http://codingfreak.blogspot.ca/2010/01/iptables-rate-limit-incoming.html

    Note that sockstress attacks are still possible even with these rules in 
    place. The attacker just needs more IP addresses to mount a successful 
    attack.

=== WHERE CAN I FIND UPDATES? ===============================================

    Find more information and updates at: https://defuse.ca/sockstress.htm

=== IS RELEASING THIS CODE ETHICAL? =========================================

    Sockstress code has existed in the wild since (at least) 2011:
        http://h.ackack.net/sockstress.html
        http://www.2shared.com/file/L4VC9Wdp/sockstresstar.html
    
    Sockstress is still somewhat effective, however, any packet hacker could
    easily write a sockstress attack tool. For this reason, I feel it is best
    to release my sockstress tool so system administrators can test their
    systems and stronger defences can be developed.

    Pretending a problem doesn't exist won't make it go away.

