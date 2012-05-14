![JBoss Admin][0]

The app will allow you to remotely administer a JBoss 7 server using the
server's exposed http management interface.

Features
--------

The application supports the following features:

* __Subsystem Metrics Monitoring__

    The metrics currently exposed are for Configuration, JVM, Data Sources, JMS Destinations, Transactions and Web subsystems (similar to those shown in the JBoss built-in web console).

* __Deployments Management__

    You can upload an artifact (installed on your iPhone through iTunes file sharing mechanism) and then enable/disable it on the server.

* __Browse the management tree__

    The whole management tree is exposed for you to configure, similar to the JBoss-cli {-gui} tool provided by the server. You can easily modify attributes and execute operations. Documentation of attributes and operation parameters (as provided by the JBoss 7 server) is easily accessed for you to refer.

Note that both operating modes (Standalone/Domain) of the server are supported. If running in "Domain" mode, you can easily switch the server you want to monitor its metrics, as well as manage deployments on each individual server-group.

Click [here][1] to watch a video demonstrating the app in "action". 

For instructions on how to setup JBoss Tools to allow connections from the app, click [here][3] for the details (thanks [Max][2]!)

I would love to hear any comments of yours, so please drop me an [email][4]! 

Enjoy!
 
[0]: http://cvasilak.org/images/jboss-admin-logo.png "JBoss Admin"
[1]: http://vimeo.com/40247548
[2]: https://twitter.com/#!/maxandersen
[3]: http://planet.jboss.org/post/using_jboss_admin_iphone_app_together_with_jboss_tools
[4]: mailto:cvasilak@gmail.gom?subject=JBoss-Admin
