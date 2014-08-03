Virtual Network Provisioner
===========================


API Details :
--

POST /provision
GET  /provision
GET  /provision/:id
GET  /provision/:id/stats


###1. POST /provision

Description:

called by :  VNET Controller

Request JSON

```
{
	"name":"m1",
	"memory":"128m",
	"vcpus":"2",
	"type":"router",
	"Services":[{"name":"quagga","enabled":true,"config":{}}],	
	"ifmap":[
		{"ifname":"eth0","hwAddress":"00:16:3e:5a:55:11","ipaddress":"10.0.3.2","netmask":"255.255.255.0","type":"mgmt"},
		{"ifname":"eth1","hwAddress":"00:16:3e:5a:55:15","brname":"wan_m1_m2","ipaddress":"172.16.1.1","netmask":"255.255.255.252","type":"wan","veth":"veth_m1_eth1"},
		{"ifname":"eth2","hwAddress":"00:16:3e:5a:55:17","brname":"sw1","ipaddress":"10.10.10.1","netmask":"255.255.255.224","type":"lan","veth":"veth_m1_eth2"}
		],
	"id":"55d2375c-275b-47af-a439-24c968403090"
	}

```

Response:
Success case:

```
{
	"id":"252fe497-1b9f-4ccd-9858-ea32f9e550ce",
	"status":"provisioned"
}
```


Failure case:

```
{
	"id" : "252fe497-1b9f-4ccd-9858-ea32f9e550ce",
	"status" : "failed-in-provision"
	"reason" : "failed to start quagga service"
}
```

###2) GET  /provision

Description :  Get all the Node details available in provisioned DB.

Not used.

###3)GET  /provision/:id

Description :  Get  the Node :id details available in provisioned DB.

Not used.


###4)GET  /collect/:id/stats

Description :  collect the interface and route stats from the vm  (call the plugin and get the details) and respond.

Response 
```
{
    "linkstats": [
        {
            "interface": "lo:",
            "status": "<LOOPBACK,UP,LOWER_UP>",
            "mtu": "65536",
            "qdisc": "noqueue",
            "state": "UNKNOWN",
            "mode": "DEFAULT",
            "group": "default",
            "link": "link/loopback",
            "brd": "brd",
            "rxbytes": "4736",
            "rxpackets": "64",
            "rxerror": "0",
            "rxdropped": "0",
            "rxoverrun": "0",
            "rxmcast": "0",
            "txbytes": "4736",
            "txpackets": "64",
            "txerrors": "0",
            "txdropped": "0",
            "txcarrier": "0",
            "txcollisions": "0"
        },
        {
            "interface": "eth0:",
            "status": "<BROADCAST,MULTICAST,UP,LOWER_UP>",
            "mtu": "1500",
            "qdisc": "pfifo_fast",
            "state": "UP",
            "mode": "DEFAULT",
            "group": "default",
            "link": "link/ether",
            "brd": "brd",
            "rxbytes": "20733",
            "rxpackets": "218",
            "rxerror": "0",
            "rxdropped": "0",
            "rxoverrun": "0",
            "rxmcast": "0",
            "txbytes": "564894",
            "txpackets": "147",
            "txerrors": "0",
            "txdropped": "0",
            "txcarrier": "0",
            "txcollisions": "0"
        },
        {
            "interface": "eth1:",
            "status": "<BROADCAST,MULTICAST,UP,LOWER_UP>",
            "mtu": "1500",
            "qdisc": "pfifo_fast",
            "state": "UP",
            "mode": "DEFAULT",
            "group": "default",
            "link": "link/ether",
            "brd": "brd",
            "rxbytes": "37708",
            "rxpackets": "394",
            "rxerror": "0",
            "rxdropped": "0",
            "rxoverrun": "0",
            "rxmcast": "0",
            "txbytes": "28110",
            "txpackets": "341",
            "txerrors": "0",
            "txdropped": "0",
            "txcarrier": "0",
            "txcollisions": "0"
        },
        {
            "interface": "eth2:",
            "status": "<BROADCAST,MULTICAST,UP,LOWER_UP>",
            "mtu": "1500",
            "qdisc": "pfifo_fast",
            "state": "UP",
            "mode": "DEFAULT",
            "group": "default",
            "link": "link/ether",
            "brd": "brd",
            "rxbytes": "9912",
            "rxpackets": "56",
            "rxerror": "0",
            "rxdropped": "0",
            "rxoverrun": "0",
            "rxmcast": "0",
            "txbytes": "37562",
            "txpackets": "405",
            "txerrors": "0",
            "txdropped": "0",
            "txcarrier": "0",
            "txcollisions": "0"
        }
    ],
    "routestats": [
        {
            "destination": "10.0.3.0/24",
            "dev": "eth0",
            "proto": "kernel",
            "scope": "link",
            "src": "10.0.3.2"
        },
        {
            "destination": "10.10.10.0/30",
            "dev": "eth2",
            "proto": "kernel",
            "scope": "link",
            "src": "10.10.10.1"
        },
        {
            "destination": "10.10.10.0/27",
            "dev": "eth2",
            "proto": "kernel",
            "scope": "link",
            "src": "10.10.10.1"
        },
        {
            "destination": "10.10.10.32/30",
            "via": "172.16.1.2",
            "dev": "eth1",
            "proto": "zebra",
            "metric": "2"
        },
        {
            "destination": "10.10.10.32/27",
            "via": "172.16.1.2",
            "dev": "eth1",
            "proto": "zebra",
            "metric": "2"
        },
        {
            "destination": "172.16.1.0/30",
            "dev": "eth1",
            "proto": "kernel",
            "scope": "link",
            "src": "172.16.1.1"
        },
        {
            "destination": ""
        }
    ]
}


```


LICENSE:
===
MIT

