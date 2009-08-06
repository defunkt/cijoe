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
repo. Make sure this isn't a shared repo: Joe is gonna mess with it
and therefor needs to own it.

Need to do some massaging of your repo before the tests run, like
maybe swapping in a new database.yml? No problem - Joe will try to
run `.git/hooks/after-reset` if it exists. Do it in there.


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

Want Joe to work for multiple projects? Just start multiple instances
of Joe! He can run on any port - try `cijoe -h` for more options.



( Chris Wanstrath :: chris@ozmm.org )
