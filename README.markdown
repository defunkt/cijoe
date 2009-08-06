CI Joe
======

Because knowing is half the battle.

![The Battle](http://img.skitch.com/20090805-g4a2qhttwij8n2jr9t552efn3k.png)
 
Quickstart
----------
    
    $ rip install git://github.com/defunkt/cijoe.git
    $ git clone git://github.com/you/yourrepo.git
    $ cijoe yourrepo

Basically you need to run `cijoe` and hand it the path to a git 
repo. Make sure this isn't a shared repo: Joe needs to own it.

Need to do some massaging of your repo before the tests run, like
maybe swapping in a new database.yml? No problem - Joe will try to
run `.git/hooks/after-reset` if it exists. Do it in there. Just make
sure it's executable.


Campfire
--------

Want Joe to notify Campfire? Put this in your repo's `.git/config`:

    [campfire]
    	user = your@campfire.email
    	pass = passw0rd
    	subdomain = whatever
    	room = Awesomeness

Or do it the old fashion way:

    $ cd yourrepo
    $ git config --add campfire.user chris@ozmm.org
    $ git config --add campfire.domain github
    etc.


Multiple Projects
-----------------

Want CI for multiple projects? Just start multiple instances of Joe! 
He can run on any port - try `cijoe -h` for more options.


GitHub Integration
------------------

Any POST to Joe will trigger a build. 


HTTP Auth
---------

Worried about people triggering your builds? Setup HTTP auth:

    $ git config --add cijoe.user chris
    $ git config --add cijoe.pass secret


Other CI Servers
----------------

Need more features? More notifiers? Check out one of these bad boys:

* [Cerberus](http://cerberus.rubyforge.org/)
* [Integrity](http://integrityapp.com/)
* [CruiseControl.rb](http://cruisecontrolrb.thoughtworks.com/)
* [BuildBot](http://buildbot.net/trac)

( Chris Wanstrath :: chris@ozmm.org )
