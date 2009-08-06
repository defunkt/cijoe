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

Joe looks for various git config settings in the repo you hand it. For
instance, you can tell Joe what command to run by setting
`cijoe.runner`:

    $ git config --add cijoe.runner "rake -s test:units"
    
Joe doesn't care about Ruby, Python, or whatever. As long as the
runner returns a non-zero exit status on fail and a zero on success,
everyone is happy.

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


HTTP Auth
---------

Worried about people triggering your builds? Setup HTTP auth:

    $ git config --add cijoe.user chris
    $ git config --add cijoe.pass secret


GitHub Integration
------------------

Any POST to Joe will trigger a build. If you are hiding Joe behind
HTTP auth, that's okay - GitHub knows how to authenticate properly.

![Post-Receive URL](http://img.skitch.com/20090806-d2bxrk733gqu8m11tf4kyir5d8.png)
 
You can find the Post-Receive option under the 'Service Hooks' subtab
of your project's "Admin" tab.


Other CI Servers
----------------

Need more features? More notifiers? Check out one of these bad boys:

* [Cerberus](http://cerberus.rubyforge.org/)
* [Integrity](http://integrityapp.com/)
* [CruiseControl.rb](http://cruisecontrolrb.thoughtworks.com/)
* [BuildBot](http://buildbot.net/trac)

( Chris Wanstrath :: chris@ozmm.org )
