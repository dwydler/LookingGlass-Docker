cat <<- EOF >   /etc/systemd/system/iperf3.service
[Unit]
Description=iperf3 server
After=syslog.target network.target auditd.service

[Service]
ExecStart=/usr/bin/iperf3 -s

[Install]
WantedBy=multi-user.target
EOF

systemctl enable iperf3
service iperf3 start
service iperf3 status