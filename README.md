```
# Install SASL packages (no need for devel versions)
$ yum install cyrus-sasl cyrus-sasl-plain

# Install swig to allow generation of Ruby bindings
$ yum install swig

# Install Qpid proton development package (EPEL is required)
$ rpm -i https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
$ yum install qpid-proton-c-devel

# Install the required gem
$ bundle install

# Export AMQP access point into environment
$ export NUAGE_AMQP='amqp://user:pass@amqp_host:amqp_port'

# Run the script
$ bundle exec ruby nuage_amqp_client.rb
```

After this, you should see console log, similar to

```
[centos@centos-clean nuage_amqp_client]$ bundle exec ruby nuage_amqp_client.rb
started
opened
{"userName":"tester","enterpriseName":"csp","type":"CREATE","entityType":"enterprise","entityVersion":null,"assoicatedEvent":false,"eventReceivedTime":1506570033421,"entities":[{"children":null,"parentType":null,"entityScope":"ENTERPRISE","lastUpdatedBy":"d2dc3ac6-01a4-4755-8686-e0be7f36f088","lastUpdatedDate":1506570033000,"creationDate":1506570033000,"name":"Ansible-Test","description":"Created by Ansible","avatarType":null,"avatarData":null,"floatingIPsQuota":16,"floatingIPsUsed":0,"allowTrustedForwardingClass":false,"allowAdvancedQOSConfiguration":false,"allowedForwardingClasses":["H"],"allowGatewayManagement":false,"enableApplicationPerformanceManagement":false,"encryptionManagementMode":"DISABLED","localAS":null,"dictionaryVersion":2,"allowedForwardingMode":null,"owner":"d2dc3ac6-01a4-4755-8686-e0be7f36f088","ID":"52135f98-6657-4375-bc5f-d9ad1988583d","parentID":null,"externalID":null,"customerID":162100,"DHCPLeaseInterval":24,"enterpriseProfileID":"f1e5eb19-c67a-4651-90c1-3f84e23e1d36","receiveMultiCastListID":"081169f6-cb2f-4c6e-8e94-b701224a5141","sendMultiCastListID":"738446cc-026f-488f-9718-b13f4390857b","associatedGroupKeyEncryptionProfileID":"66019ab6-90e8-44c0-8d66-33ae6f25b933","associatedEnterpriseSecurityID":"84101ad3-41a1-4553-bfba-18e0e6fc0491","associatedKeyServerMonitorID":"b13de060-2047-4a43-b9ab-6b2f244ce1f7","LDAPEnabled":false,"LDAPAuthorizationEnabled":false,"BGPEnabled":false}],"diffMap":null,"ignoreDiffInMediationEvents":false,"updateMechanism":"DEFAULT","requestID":"a3fe32ba-59e9-4ca7-bb22-04e509c38ac2"}
...
```
